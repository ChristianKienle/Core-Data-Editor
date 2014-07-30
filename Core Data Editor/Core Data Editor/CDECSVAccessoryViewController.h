#import <Cocoa/Cocoa.h>

@class CDECSVDelimiter;
@interface CDECSVAccessoryViewController : NSViewController

#pragma mark Properties
@property (nonatomic, readonly) CDECSVDelimiter *selectedDelimiter;
@property (nonatomic, readonly) BOOL firstLineContainsColumnNames;
@property (nonatomic, readonly) NSString *dateFormat;

@end
