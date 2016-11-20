#import <Foundation/Foundation.h>

@class CDECSVImportWindowControllerResultItem;
@interface CDECSVImportWindowControllerResult : NSObject

#pragma mark Creating
- (instancetype)initWithItems:(NSArray<CDECSVImportWindowControllerResultItem*> *)items destinationEntityDescription:(NSEntityDescription *)destinationEntityDescription;

#pragma mark Properties
@property (nonatomic, copy, readonly) NSArray<CDECSVImportWindowControllerResultItem*> *items;
@property (nonatomic, strong, readonly) NSEntityDescription *destinationEntityDescription;

@end
