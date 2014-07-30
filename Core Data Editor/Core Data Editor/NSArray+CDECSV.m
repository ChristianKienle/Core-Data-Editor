#import "NSArray+CDECSV.h"
#import "CHCSVParser.h"

@interface _CDECSVAggregator : NSObject <CHCSVParserDelegate>

#pragma mark - Properties
@property (nonatomic, readwrite, copy) NSArray *lines;
@property (nonatomic, readwrite, copy) NSArray *currentLine;
@property (nonatomic, copy) NSError *error;

@end

@implementation _CDECSVAggregator {
    NSMutableArray *_lines;
    NSMutableArray *_currentLine;
}

#pragma mark - Properties
- (NSArray *)lines {
    return [_lines copy];
}

- (void)setLines:(NSArray *)lines {
    _lines = [lines mutableCopy];
}

- (NSArray *)currentLine {
    return [_currentLine copy];
}

- (void)setCurrentLine:(NSArray *)currentLine {
    _currentLine = [currentLine mutableCopy];
}


#pragma mark - Creating
- (instancetype)init {
    self = [super init];
    if(self) {
        self.lines = @[];
        self.currentLine = @[];
        self.error = nil;
    }
    return self;
}

#pragma mark - CHCSVParserDelegate
- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    self.lines = @[];
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    self.currentLine = @[];
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    [_lines addObject:_currentLine];
    self.currentLine = @[];
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    [_currentLine addObject:field];
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    self.error = error;
    self.lines = @[];
}

@end


@implementation NSArray (CDECSV)

+ (instancetype)arrayWithContentsOfURL:(NSURL *)URL delimiter:(NSString *)delimiter error_cde:(NSError **)error {
    NSInputStream *input = [NSInputStream inputStreamWithURL:URL];
    CHCSVParser *parser = [[CHCSVParser alloc] initWithInputStream:input usedEncoding:NULL delimiter:[delimiter characterAtIndex:0]];
    _CDECSVAggregator *aggregator = [_CDECSVAggregator new];
    [parser setDelegate:aggregator];
    [parser setRecognizesBackslashesAsEscapes:YES];
    [parser setSanitizesFields:YES];
    [parser setRecognizesComments:YES];
    [parser setStripsLeadingAndTrailingWhitespace:NO];
    [parser parse];
    NSArray *final = [aggregator lines];
    return final;
}

+ (instancetype)arrayWithContentsOfCSVString:(NSString *)csvString delimiter:(NSString *)delimiter error_cde:(NSError **)error {
    NSParameterAssert(csvString);
    
    _CDECSVAggregator *aggregator = [_CDECSVAggregator new];
    NSStringEncoding encoding = [csvString fastestEncoding];
    NSInputStream *stream = [NSInputStream inputStreamWithData:[csvString dataUsingEncoding:encoding]];

    CHCSVParser *parser = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:NULL delimiter:[delimiter characterAtIndex:0]];
    [parser setDelegate:aggregator];
    
    [parser setRecognizesBackslashesAsEscapes:YES];
    [parser setSanitizesFields:YES];
    [parser setRecognizesComments:YES];
    [parser setStripsLeadingAndTrailingWhitespace:NO];
    
    [parser parse];
    
    NSArray *final = [aggregator lines];
    
    return final;

}

@end
