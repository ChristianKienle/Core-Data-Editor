#import "CDEEntityAutosaveInformation.h"
#import "CDEEntityAutosaveInformationItem.h"

@interface CDEEntityAutosaveInformation ()

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSString *entityName;
@property (nonatomic, copy, readwrite) NSArray *items; // contains CDEEntityAutosaveInformationItems

@end

@implementation CDEEntityAutosaveInformation
#pragma mark - Creating
- (instancetype)initWithEntityName:(NSString *)entityName items:(NSArray *)items {
    NSParameterAssert(entityName);
    
    self = [super init];
    if(self) {
        self.entityName = entityName;
        self.items = (items != nil ? items : @[]);
    }
    return self;
}

+ (instancetype)newWithEntityName:(NSString *)entityName items:(NSArray *)items {
    return [[self alloc] initWithEntityName:entityName items:items];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"CDEInvalidInitializer" reason:nil userInfo:nil];
}

#pragma mark - Properties
- (NSDictionary *)dictionaryRepresentation {
    NSMutableArray *itemsAsDictionaries = [NSMutableArray new];
    for(CDEEntityAutosaveInformationItem *item in self.items) {
        [itemsAsDictionaries addObject:item.dictionaryRepresentation];
    }
    return @{ self.entityName : itemsAsDictionaries };
}

#pragma mark - Equality
- (BOOL)isEqualToEntityAutosaveInformation:(CDEEntityAutosaveInformation *)entityAutosaveInformation {
    if(entityAutosaveInformation == nil) {
        return NO;
    }
    
    if(self == entityAutosaveInformation) {
        return YES;
    }
    
    if([self.entityName isEqualToString:entityAutosaveInformation.entityName] == NO) {
        return NO;
    }
    
    // Equality for every item
    NSArray *otherItems = entityAutosaveInformation.items;
    
    if(self.items.count != otherItems.count) {
        return NO;
    }
    
    // same count
    NSUInteger index = 0;
    for(CDEEntityAutosaveInformationItem *item in self.items) {
        CDEEntityAutosaveInformationItem *otherItem = otherItems[index];
        BOOL itemsEqual = [otherItem isEqualToItem:item];
        if(itemsEqual == NO) {
            return NO;
        }
        index++;
    }
    return YES;
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ = %@", [super description], self.entityName, self.items];
}

@end
