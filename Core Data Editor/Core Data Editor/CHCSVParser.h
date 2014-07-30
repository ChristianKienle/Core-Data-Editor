//
//  CHCSVParser.h
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

#import <Foundation/Foundation.h>

extern NSString * const CHCSVErrorDomain;

enum {
    CHCSVErrorCodeInvalidFormat = 1,
};

typedef NSInteger CHCSVErrorCode;

@class CHCSVParser;
@protocol CHCSVParserDelegate <NSObject>

@optional
- (void)parserDidBeginDocument:(CHCSVParser *)parser;
- (void)parserDidEndDocument:(CHCSVParser *)parser;

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber;
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber;

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex;
- (void)parser:(CHCSVParser *)parser didReadComment:(NSString *)comment;

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error;

@end

@interface CHCSVParser : NSObject

@property (assign) id<CHCSVParserDelegate> delegate;
@property (assign) BOOL recognizesBackslashesAsEscapes; // default is NO
@property (assign) BOOL sanitizesFields; // default is NO
@property (assign) BOOL recognizesComments; // default is NO
@property (assign) BOOL stripsLeadingAndTrailingWhitespace; // default is NO

@property (readonly) NSUInteger totalBytesRead;

// designated initializer
- (id)initWithInputStream:(NSInputStream *)stream usedEncoding:(NSStringEncoding *)encoding delimiter:(unichar)delimiter;

- (id)initWithCSVString:(NSString *)csv;
- (id)initWithContentsOfCSVFile:(NSString *)csvFilePath;

- (void)parse;
- (void)cancelParsing;

@end

@interface CHCSVWriter : NSObject

- (instancetype)initForWritingToCSVFile:(NSString *)path;
- (instancetype)initWithOutputStream:(NSOutputStream *)stream encoding:(NSStringEncoding)encoding delimiter:(unichar)delimiter;

- (void)writeField:(NSString *)field;
- (void)finishLine;

- (void)writeLineOfFields:(id<NSFastEnumeration>)fields;

- (void)writeComment:(NSString *)comment;

- (void)closeStream;

@end

#pragma mark - Convenience Categories

typedef NS_OPTIONS(NSUInteger, CHCSVParserOptions) {
    CHCSVParserOptionsRecognizesBackslashesAsEscapes = 1 << 0,
    CHCSVParserOptionsSanitizesFields = 1 << 1,
    CHCSVParserOptionsRecognizesComments = 1 << 2,
    CHCSVParserOptionsStripsLeadingAndTrailingWhitespace = 1 << 3
};

@interface NSArray (CHCSVAdditions)

+ (instancetype)arrayWithContentsOfCSVFile:(NSString *)csvFilePath;
+ (instancetype)arrayWithContentsOfCSVFile:(NSString *)csvFilePath options:(CHCSVParserOptions)options;
- (NSString *)CSVString;

@end

@interface NSString (CHCSVAdditions)

- (NSArray *)CSVComponents;
- (NSArray *)CSVComponentsWithOptions:(CHCSVParserOptions)options;

@end
