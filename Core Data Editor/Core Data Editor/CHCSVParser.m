 //
//  CHCSVParser.m
//  CHCSVParser
/**
 Copyright (c) 2012 Dave DeLong
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 **/

#import "CHCSVParser.h"

NSString *const CHCSVErrorDomain = @"com.davedelong.csv";

#define CHUNK_SIZE 512
#define DOUBLE_QUOTE '"'
#define COMMA ','
#define OCTOTHORPE '#'
#define BACKSLASH '\\'

#if __has_feature(objc_arc)

#define CHCSV_HAS_ARC 1
#define CHCSV_RETAIN(_o) (_o)
#define CHCSV_RELEASE(_o)
#define CHCSV_AUTORELEASE(_o) (_o)

#else

#define CHCSV_HAS_ARC 0
#define CHCSV_RETAIN(_o) [(_o) retain]
#define CHCSV_RELEASE(_o) [(_o) release]
#define CHCSV_AUTORELEASE(_o) [(_o) autorelease]

#endif

@interface CHCSVParser ()
@property (assign) NSUInteger totalBytesRead;
@end

@implementation CHCSVParser {
    NSInputStream *_stream;
    NSStringEncoding _streamEncoding;
    NSMutableData *_stringBuffer;
    NSMutableString *_string;
    NSCharacterSet *_validFieldCharacters;
    
    NSUInteger _nextIndex;
    
    NSInteger _fieldIndex;
    NSRange _fieldRange;
    NSMutableString *_sanitizedField;
    
    unichar _delimiter;
    
    NSError *_error;
    
    NSUInteger _currentRecord;
    BOOL _cancelled;
}

- (id)initWithCSVString:(NSString *)csv {
    NSStringEncoding encoding = [csv fastestEncoding];
    NSInputStream *stream = [NSInputStream inputStreamWithData:[csv dataUsingEncoding:encoding]];
    return [self initWithInputStream:stream usedEncoding:&encoding delimiter:COMMA];
}

- (id)initWithContentsOfCSVFile:(NSString *)csvFilePath {
    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:csvFilePath];
    NSStringEncoding encoding = 0;
    return [self initWithInputStream:stream usedEncoding:&encoding delimiter:COMMA];
}

- (id)initWithInputStream:(NSInputStream *)stream usedEncoding:(NSStringEncoding *)encoding delimiter:(unichar)delimiter {
    NSParameterAssert(stream);
    NSParameterAssert(delimiter);
    NSAssert([[NSCharacterSet newlineCharacterSet] characterIsMember:delimiter] == NO, @"The field delimiter may not be a newline");
    NSAssert(delimiter != DOUBLE_QUOTE, @"The field delimiter may not be a double quote");
    NSAssert(delimiter != OCTOTHORPE, @"The field delimiter may not be an octothorpe");
    
    self = [super init];
    if (self) {
        _stream = CHCSV_RETAIN(stream);
        [_stream open];
        
        _stringBuffer = [[NSMutableData alloc] init];
        _string = [[NSMutableString alloc] init];
        
        _delimiter = delimiter;
        
        _nextIndex = 0;
        _recognizesComments = NO;
        _recognizesBackslashesAsEscapes = NO;
        _sanitizesFields = NO;
        _sanitizedField = [[NSMutableString alloc] init];
        _stripsLeadingAndTrailingWhitespace = NO;
        
        NSMutableCharacterSet *m = [[NSCharacterSet newlineCharacterSet] mutableCopy];
        NSString *invalid = [NSString stringWithFormat:@"%c%C", DOUBLE_QUOTE, _delimiter];
        [m addCharactersInString:invalid];
        _validFieldCharacters = CHCSV_RETAIN([m invertedSet]);
        CHCSV_RELEASE(m);
        
        if (encoding == NULL || *encoding == 0) {
            // we need to determine the encoding
            [self _sniffEncoding];
            if (encoding) {
                *encoding = _streamEncoding;
            }
        } else {
            _streamEncoding = *encoding;
        }
    }
    return self;
}

- (void)dealloc {
    [_stream close];
#if !CHCSV_HAS_ARC
    [_stream release];
    [_stringBuffer release];
    [_string release];
    [_sanitizedField release];
    [_validFieldCharacters release];
    [super dealloc];
#endif
}

#pragma mark -

- (void)_sniffEncoding {
    NSStringEncoding encoding = NSUTF8StringEncoding;
    
    uint8_t bytes[CHUNK_SIZE];
    NSInteger readLength = [_stream read:bytes maxLength:CHUNK_SIZE];
    if (readLength > 0 && readLength <= CHUNK_SIZE) {
        [_stringBuffer appendBytes:bytes length:readLength];
        [self setTotalBytesRead:[self totalBytesRead] + readLength];
        
        NSInteger bomLength = 0;
        
        if (readLength > 3 && bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0xFE && bytes[3] == 0xFF) {
            encoding = NSUTF32BigEndianStringEncoding;
            bomLength = 4;
        } else if (readLength > 3 && bytes[0] == 0xFF && bytes[1] == 0xFE && bytes[2] == 0x00 && bytes[3] == 0x00) {
            encoding = NSUTF32LittleEndianStringEncoding;
            bomLength = 4;
        } else if (readLength > 3 && bytes[0] == 0x1B && bytes[1] == 0x24 && bytes[2] == 0x29 && bytes[3] == 0x43) {
            encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISO_2022_KR);
            bomLength = 4;
        } else if (readLength > 1 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
            encoding = NSUTF16BigEndianStringEncoding;
            bomLength = 2;
        } else if (readLength > 1 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
            encoding = NSUTF16LittleEndianStringEncoding;
            bomLength = 2;
        } else if (readLength > 2 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
            encoding = NSUTF8StringEncoding;
            bomLength = 3;
        } else {
            NSString *bufferAsUTF8 = nil;
            
            for (NSInteger triedLength = 0; triedLength < 4; ++triedLength) {
                bufferAsUTF8 = CHCSV_AUTORELEASE([[NSString alloc] initWithBytes:bytes length:readLength-triedLength encoding:NSUTF8StringEncoding]);
                if (bufferAsUTF8 != nil) {
                    break;
                }
            }
            
            if (bufferAsUTF8 != nil) {
                encoding = NSUTF8StringEncoding;
            } else {
                NSLog(@"unable to determine stream encoding; assuming MacOSRoman");
                encoding = NSMacOSRomanStringEncoding;
            }
        }
        
        if (bomLength > 0) {
            [_stringBuffer replaceBytesInRange:NSMakeRange(0, bomLength) withBytes:NULL length:0];
        }
    }
    _streamEncoding = encoding;
}

- (void)_loadMoreIfNecessary {
    NSUInteger stringLength = [_string length];
    NSUInteger reloadPortion = stringLength / 3;
    if (reloadPortion < 10) { reloadPortion = 10; }
    
    if ([_stream hasBytesAvailable] && _nextIndex+reloadPortion >= stringLength) {
        // read more from the stream
        uint8_t buffer[CHUNK_SIZE];
        NSInteger readBytes = [_stream read:buffer maxLength:CHUNK_SIZE];
        if (readBytes > 0) {
            // append it to the buffer
            [_stringBuffer appendBytes:buffer length:readBytes];
            [self setTotalBytesRead:[self totalBytesRead] + readBytes];
        }
    }
    
    if ([_stringBuffer length] > 0) {
        // try to turn the next portion of the buffer into a string
        NSUInteger readLength = [_stringBuffer length];
        while (readLength > 0) {
            NSString *readString = [[NSString alloc] initWithBytes:[_stringBuffer bytes] length:readLength encoding:_streamEncoding];
            if (readString == nil) {
                readLength--;
            } else {
                [_string appendString:readString];
                CHCSV_RELEASE(readString);
                break;
            }
        };
        
        [_stringBuffer replaceBytesInRange:NSMakeRange(0, readLength) withBytes:NULL length:0];
    }
}

- (void)_advance {
    [self _loadMoreIfNecessary];
    _nextIndex++;
}

- (unichar)_peekCharacter {
    [self _loadMoreIfNecessary];
    if (_nextIndex >= [_string length]) { return '\0'; }
    
    return [_string characterAtIndex:_nextIndex];
}

- (unichar)_peekPeekCharacter {
    [self _loadMoreIfNecessary];
    NSUInteger nextNextIndex = _nextIndex+1;
    if (nextNextIndex >= [_string length]) { return '\0'; }
    
    return [_string characterAtIndex:nextNextIndex];
}

#pragma mark -

- (void)parse {
    [self _beginDocument];
    
    _currentRecord = 0;
    while ([self _parseRecord]) {
        ; // yep;
    }
    
    if (_error != nil) {
        [self _error];
    } else {
        [self _endDocument];
    }
}

- (void)cancelParsing {
    _cancelled = YES;
}

- (BOOL)_parseRecord {
    while ([self _peekCharacter] == OCTOTHORPE && _recognizesComments) {
        [self _parseComment];
    }
    
    [self _beginRecord];
    while (1) {
        if (![self _parseField]) {
            break;
        }
        if (![self _parseDelimiter]) {
            break;
        }
    }    
    BOOL followedByNewline = [self _parseNewline];
    [self _endRecord];
    
    return (followedByNewline && _error == nil);
}

- (BOOL)_parseNewline {
    if (_cancelled) { return NO; }
    
    NSUInteger charCount = 0;
    while ([[NSCharacterSet newlineCharacterSet] characterIsMember:[self _peekCharacter]]) {
        charCount++;
        [self _advance];
    }
    return (charCount > 0);
}

- (BOOL)_parseComment {
    [self _advance]; // consume the octothorpe
    
    NSCharacterSet *newlines = [NSCharacterSet newlineCharacterSet];
    
    [self _beginComment];
    BOOL isBackslashEscaped = NO;
    while (1) {
        if (isBackslashEscaped == NO) {
            unichar next = [self _peekCharacter];
            if (next == BACKSLASH && _recognizesBackslashesAsEscapes) {
                isBackslashEscaped = YES;
                [self _advance];
            } else if ([newlines characterIsMember:next] == NO) {
                [self _advance];
            } else {
                // it's a newline
                break;
            }
        } else {
            isBackslashEscaped = YES;
            [self _advance];
        }
    }
    [self _endComment];
    
    return [self _parseNewline];
}

- (void)_parseFieldWhitespace {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    while ([self _peekCharacter] != '\0' &&
           [whitespace characterIsMember:[self _peekCharacter]] &&
           [self _peekCharacter] != _delimiter) {
        // if we're sanitizing fields, then these characters would be stripped (because they're not appended to _sanitizedField)
        // if we're not sanitizing fields, then they'll be included in the -substringWithRange:
        [self _advance];
    }
}

- (BOOL)_parseField {
    if (_cancelled) { return NO; }
    
    BOOL parsedField = NO;
    [self _beginField];
    if (_stripsLeadingAndTrailingWhitespace) {
        // consume leading whitespace
        [self _parseFieldWhitespace];
    }
    
    if ([self _peekCharacter] == DOUBLE_QUOTE) {
        parsedField = [self _parseEscapedField];
    } else {
        parsedField = [self _parseUnescapedField];
        if (_stripsLeadingAndTrailingWhitespace) {
            NSString *trimmedString = [_sanitizedField stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [_sanitizedField setString:trimmedString];
        }
    }
    
    if (parsedField) {
        if (_stripsLeadingAndTrailingWhitespace) {
            // consume trailing whitespace
            [self _parseFieldWhitespace];
        }
        [self _endField];
    }
    return parsedField;
}

- (BOOL)_parseEscapedField {
    [self _advance]; // consume the opening double quote
    
    NSCharacterSet *newlines = [NSCharacterSet newlineCharacterSet];
    BOOL isBackslashEscaped = NO;
    while (1) {
        unichar next = [self _peekCharacter];
        if (next == '\0') { break; }
        
        if (isBackslashEscaped == NO) {
            if (next == BACKSLASH && _recognizesBackslashesAsEscapes) {
                isBackslashEscaped = YES;
                [self _advance]; // consume the backslash
            } else if ([_validFieldCharacters characterIsMember:next] ||
                       [newlines characterIsMember:next] ||
                       next == _delimiter) {
                [_sanitizedField appendFormat:@"%C", next];
                [self _advance];
            } else if (next == DOUBLE_QUOTE && [self _peekPeekCharacter] == DOUBLE_QUOTE) {
                [_sanitizedField appendFormat:@"%C", next];
                [self _advance];
                [self _advance];
            } else {
                // not valid, or it's not a doubled double quote
                break;
            }
        } else {
            [_sanitizedField appendFormat:@"%C", next];
            isBackslashEscaped = NO;
            [self _advance];
        }
    }
    
    if ([self _peekCharacter] == DOUBLE_QUOTE) {
        [self _advance];
        return YES;
    }
    
    return NO;
}

- (BOOL)_parseUnescapedField {
    
    BOOL isBackslashEscaped = NO;
    while (1) {
        unichar next = [self _peekCharacter];
        if (next == '\0') { break; }
        
        if (isBackslashEscaped == NO) {
            if (next == BACKSLASH && _recognizesBackslashesAsEscapes) {
                isBackslashEscaped = YES;
                [self _advance];
            } else if ([_validFieldCharacters characterIsMember:next]) {
                [_sanitizedField appendFormat:@"%C", next];
                [self _advance];
            } else {
                break;
            }
        } else {
            isBackslashEscaped = NO;
            [_sanitizedField appendFormat:@"%C", next];
            [self _advance];
        }
    }
    
    return YES;
}

- (BOOL)_parseDelimiter {
    unichar next = [self _peekCharacter];
    if (next == _delimiter) {
        [self _advance];
        return YES;
    }
    if (next != '\0' && [[NSCharacterSet newlineCharacterSet] characterIsMember:next] == NO) {
        NSString *description = [NSString stringWithFormat:@"Unexpected delimiter. Expected '%C' (0x%X), but got '%C' (0x%X)", _delimiter, _delimiter, [self _peekCharacter], [self _peekCharacter]];
        _error = [[NSError alloc] initWithDomain:CHCSVErrorDomain code:CHCSVErrorCodeInvalidFormat userInfo:@{NSLocalizedDescriptionKey : description}];
    }
    return NO;
}

- (void)_beginDocument {
    if ([_delegate respondsToSelector:@selector(parserDidBeginDocument:)]) {
        [_delegate parserDidBeginDocument:self];
    }
}

- (void)_endDocument {
    if ([_delegate respondsToSelector:@selector(parserDidEndDocument:)]) {
        [_delegate parserDidEndDocument:self];
    }
}

- (void)_beginRecord {
    if (_cancelled) { return; }
    
    _fieldIndex = 0;
    _currentRecord++;
    if ([_delegate respondsToSelector:@selector(parser:didBeginLine:)]) {
        [_delegate parser:self didBeginLine:_currentRecord];
    }
}

- (void)_endRecord {
    if (_cancelled) { return; }
    
    if ([_delegate respondsToSelector:@selector(parser:didEndLine:)]) {
        [_delegate parser:self didEndLine:_currentRecord];
    }
}

- (void)_beginField {
    if (_cancelled) { return; }
    
    [_sanitizedField setString:@""];
    _fieldRange.location = _nextIndex;
}

- (void)_endField {
    if (_cancelled) { return; }
    
    _fieldRange.length = (_nextIndex - _fieldRange.location);
    NSString *field = nil;
    
    if (_sanitizesFields) {
        field = CHCSV_AUTORELEASE([_sanitizedField copy]);
    } else {
        field = [_string substringWithRange:_fieldRange];
        if (_stripsLeadingAndTrailingWhitespace) {
            field = [field stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(parser:didReadField:atIndex:)]) {
        [_delegate parser:self didReadField:field atIndex:_fieldIndex];
    }
    
    [_string replaceCharactersInRange:NSMakeRange(0, NSMaxRange(_fieldRange)) withString:@""];
    _nextIndex = 0;
    _fieldIndex++;
}

- (void)_beginComment {
    if (_cancelled) { return; }
    
    _fieldRange.location = _nextIndex;
}

- (void)_endComment {
    if (_cancelled) { return; }
    
    _fieldRange.length = (_nextIndex - _fieldRange.location);
    if ([_delegate respondsToSelector:@selector(parser:didReadComment:)]) {
        NSString *comment = [_string substringWithRange:_fieldRange];
        [_delegate parser:self didReadComment:comment];
    }
    
    [_string replaceCharactersInRange:NSMakeRange(0, NSMaxRange(_fieldRange)) withString:@""];
    _nextIndex = 0;
}

- (void)_error {
    if (_cancelled) { return; }
    
    if ([_delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        [_delegate parser:self didFailWithError:_error];
    }
}

@end

@implementation CHCSVWriter {
    NSOutputStream *_stream;
    NSStringEncoding _streamEncoding;
    
    NSData *_delimiter;
    NSData *_bom;
    NSCharacterSet *_illegalCharacters;
    
    NSUInteger _currentField;
}

- (instancetype)initForWritingToCSVFile:(NSString *)path {
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    return [self initWithOutputStream:stream encoding:NSUTF8StringEncoding delimiter:COMMA];
}

- (instancetype)initWithOutputStream:(NSOutputStream *)stream encoding:(NSStringEncoding)encoding delimiter:(unichar)delimiter {
    self = [super init];
    if (self) {
        _stream = CHCSV_RETAIN(stream);
        _streamEncoding = encoding;
        
        if ([_stream streamStatus] == NSStreamStatusNotOpen) {
            [_stream open];
        }
        
        NSData *a = [@"a" dataUsingEncoding:_streamEncoding];
        NSData *aa = [@"aa" dataUsingEncoding:_streamEncoding];
        if ([a length] * 2 != [aa length]) {
            NSUInteger characterLength = [aa length] - [a length];
            _bom = CHCSV_RETAIN([a subdataWithRange:NSMakeRange(0, [a length] - characterLength)]);
            [self _writeData:_bom];
        }
        
        NSString *delimiterString = [NSString stringWithFormat:@"%C", delimiter];
        NSData *delimiterData = [delimiterString dataUsingEncoding:_streamEncoding];
        if ([_bom length] > 0) {
            _delimiter = CHCSV_RETAIN([delimiterData subdataWithRange:NSMakeRange([_bom length], [delimiterData length] - [_bom length])]);
        } else {
            _delimiter = CHCSV_RETAIN(delimiterData);
        }
        
        NSMutableCharacterSet *illegalCharacters = [[NSCharacterSet newlineCharacterSet] mutableCopy];
        [illegalCharacters addCharactersInString:delimiterString];
        [illegalCharacters addCharactersInString:@"\""];
        _illegalCharacters = [illegalCharacters copy];
        CHCSV_RELEASE(illegalCharacters);
    }
    return self;
}

- (void)dealloc {
    [self closeStream];
    
#if !CHCSV_HAS_ARC
    [_delimiter release];
    [_bom release];
    [_illegalCharacters release];
    [super dealloc];
#endif
}

- (void)_writeData:(NSData *)data {
    if ([data length] > 0) {
        const void *bytes = [data bytes];
        [_stream write:bytes maxLength:[data length]];
    }
}

- (void)_writeString:(NSString *)string {
    NSData *stringData = [string dataUsingEncoding:_streamEncoding];
    if ([_bom length] > 0) {
        stringData = [stringData subdataWithRange:NSMakeRange([_bom length], [stringData length] - [_bom length])];
    }
    [self _writeData:stringData];
}

- (void)_writeDelimiter {
    [self _writeData:_delimiter];
}

- (void)writeField:(id)field {
    if (_currentField > 0) {
        [self _writeDelimiter];
    }
    NSString *string = field ? [field description] : @"";
    if ([string rangeOfCharacterFromSet:_illegalCharacters].location != NSNotFound) {
        // replace double quotes with double double quotes
        string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        // surround in double quotes
        string = [NSString stringWithFormat:@"\"%@\"", string];
    }
    [self _writeString:string];
    _currentField++;
}

- (void)finishLine {
    [self _writeString:@"\n"];
    _currentField = 0;
}

- (void)_finishLineIfNecessary {
    if (_currentField != 0) {
        [self finishLine];
    }
}

- (void)writeLineOfFields:(id<NSFastEnumeration>)fields {
    [self _finishLineIfNecessary];
    
    for (id field in fields) {
        [self writeField:field];
    }
    [self finishLine];
}

- (void)writeComment:(NSString *)comment {
    [self _finishLineIfNecessary];
    
    NSArray *lines = [comment componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        NSString *commented = [NSString stringWithFormat:@"#%@\n", line];
        [self _writeString:commented];
    }
}

- (void)closeStream {
    [_stream close];
    CHCSV_RELEASE(_stream);
    _stream = nil;
}

@end

#pragma mark - Convenience Categories

@interface _CHCSVAggregator : NSObject <CHCSVParserDelegate>

@property (readonly) NSArray *lines;
@property (readonly) NSError *error;

@end

@implementation _CHCSVAggregator {
    NSMutableArray *_lines;
    NSMutableArray *_currentLine;
}

#if !CHCSV_HAS_ARC
- (void)dealloc {
    [_currentLine release];
    [_lines release];
    [_error release];
    [super dealloc];
}
#endif

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    _lines = [[NSMutableArray alloc] init];
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    _currentLine = [[NSMutableArray alloc] init];
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    [_lines addObject:_currentLine];
    CHCSV_RELEASE(_currentLine);
    _currentLine = nil;
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    [_currentLine addObject:field];
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    _error = CHCSV_RETAIN(error);
    CHCSV_RELEASE(_lines);
    _lines = nil;
}

@end

@implementation NSArray (CHCSVAdditions)

+ (instancetype)arrayWithContentsOfCSVFile:(NSString *)csvFilePath {
    return [self arrayWithContentsOfCSVFile:csvFilePath options:0];
}

+ (instancetype)arrayWithContentsOfCSVFile:(NSString *)csvFilePath options:(CHCSVParserOptions)options{
    NSParameterAssert(csvFilePath);
    _CHCSVAggregator *aggregator = [[_CHCSVAggregator alloc] init];
    CHCSVParser *parser = [[CHCSVParser alloc] initWithContentsOfCSVFile:csvFilePath];
    [parser setDelegate:aggregator];
    
    [parser setRecognizesBackslashesAsEscapes:!!(options & CHCSVParserOptionsRecognizesBackslashesAsEscapes)];
    [parser setSanitizesFields:!!(options & CHCSVParserOptionsSanitizesFields)];
    [parser setRecognizesComments:!!(options & CHCSVParserOptionsRecognizesComments)];
    [parser setStripsLeadingAndTrailingWhitespace:!!(options & CHCSVParserOptionsStripsLeadingAndTrailingWhitespace)];
    
    [parser parse];
    CHCSV_RELEASE(parser);
    
    NSArray *final = CHCSV_AUTORELEASE(CHCSV_RETAIN([aggregator lines]));
    CHCSV_RELEASE(aggregator);
    
    return final;
}

- (NSString *)CSVString {
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    CHCSVWriter *writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:COMMA];
    for (id object in self) {
        if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
            [writer writeLineOfFields:object];
        }
    }
    [writer closeStream];
    CHCSV_RELEASE(writer);
    
    NSData *buffer = [output propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    NSString *string = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
    return CHCSV_AUTORELEASE(string);
}

@end

@implementation NSString (CHCSVAdditions)

- (NSArray *)CSVComponents {
    return [self CSVComponentsWithOptions:0];
}

- (NSArray *)CSVComponentsWithOptions:(CHCSVParserOptions)options {
    _CHCSVAggregator *aggregator = [[_CHCSVAggregator alloc] init];
    CHCSVParser *parser = [[CHCSVParser alloc] initWithCSVString:self];
    [parser setDelegate:aggregator];
    
    [parser setRecognizesBackslashesAsEscapes:!!(options & CHCSVParserOptionsRecognizesBackslashesAsEscapes)];
    [parser setSanitizesFields:!!(options & CHCSVParserOptionsSanitizesFields)];
    [parser setRecognizesComments:!!(options & CHCSVParserOptionsRecognizesComments)];
    [parser setStripsLeadingAndTrailingWhitespace:!!(options & CHCSVParserOptionsStripsLeadingAndTrailingWhitespace)];
    
    [parser parse];
    CHCSV_RELEASE(parser);
    
    NSArray *final = CHCSV_AUTORELEASE(CHCSV_RETAIN([aggregator lines]));
    CHCSV_RELEASE(aggregator);
    
    return final;
}

@end
