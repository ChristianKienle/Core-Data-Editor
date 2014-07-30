#import "CDECSVImportWindowControllerResultItem.h"

@interface CDECSVImportWindowControllerResultItem ()

#pragma mark Properties
@property (nonatomic, copy, readwrite) NSDictionary *keyedValuesForUsedAttributes;

@end

@implementation CDECSVImportWindowControllerResultItem

#pragma mark Creating
- (instancetype)initWithKeyedValuesForUsedAttributes:(NSDictionary *)keyedValuesForUsedAttributes {
    self = [super init];
    if(self) {
        self.keyedValuesForUsedAttributes = keyedValuesForUsedAttributes;
    }
    return self;
}

- (instancetype)init {
    return [self initWithKeyedValuesForUsedAttributes:@{}];
}

@end
