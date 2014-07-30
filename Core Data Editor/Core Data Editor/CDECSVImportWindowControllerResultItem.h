#import <Foundation/Foundation.h>

@interface CDECSVImportWindowControllerResultItem : NSObject

#pragma mark Creating
- (instancetype)initWithKeyedValuesForUsedAttributes:(NSDictionary *)keyedValuesForUsedAttributes;

#pragma mark Properties
@property (nonatomic, copy, readonly) NSDictionary *keyedValuesForUsedAttributes;

@end
