#import <Foundation/Foundation.h>

@interface CDECSVDelimiter : NSObject

#pragma mark Getting Delimiter Instances
+ (CDECSVDelimiter *)delimiterForMenuItemTag:(NSInteger)menuItemTag;

#pragma mark Properties
@property (nonatomic, copy, readonly) NSString *stringRepresentation;
@property (nonatomic, assign, readonly) NSInteger menuItemTag;

@end
