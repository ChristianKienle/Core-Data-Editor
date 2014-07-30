#import <Cocoa/Cocoa.h>

@interface CDECodeGeneratorAccessoryViewController : NSViewController

#pragma mark Creating an Instance
- (instancetype)init;

#pragma mark Properties
@property (nonatomic, copy) NSNumber *generateARCCompatibleCode;
@property (nonatomic, copy) NSNumber *generateFetchResultsControllerCode;

@end
