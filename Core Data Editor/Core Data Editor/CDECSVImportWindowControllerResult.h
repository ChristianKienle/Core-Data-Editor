#import <Foundation/Foundation.h>

@interface CDECSVImportWindowControllerResult : NSObject

#pragma mark Creating
- (instancetype)initWithItems:(NSArray *)items destinationEntityDescription:(NSEntityDescription *)destinationEntityDescription;

#pragma mark Properties
@property (nonatomic, copy, readonly) NSArray *items;
@property (nonatomic, strong, readonly) NSEntityDescription *destinationEntityDescription;

@end
