#import "CDEAutosaveInformation.h"
#import "CDEEntityAutosaveInformation.h"
#import "CDEEntityAutosaveInformationItem.h"

@interface CDEAutosaveInformation ()

#pragma mark - Properties
@property (nonatomic, copy) NSDictionary *entityInformationByName;

@end

@implementation CDEAutosaveInformation {
    NSMutableDictionary *_entityInformationByName;
}

#pragma mark - Creating
- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation {
    self = [super init];
    if(self) {
        self.entityInformationByName = @{};
        [self _setupWithDictionaryRepresentation:(dictionaryRepresentation != nil ? dictionaryRepresentation : @{})];
    }
    return self;
}

- (instancetype)init {
    return [self initWithDictionaryRepresentation:@{}];
}

#pragma mark - Working with the Information
- (CDEEntityAutosaveInformation *)informationForEntityNamed:(NSString *)name {
    NSParameterAssert(name);
    return _entityInformationByName[name];
}

- (void)setInformation:(CDEEntityAutosaveInformation *)information forEntityNamed:(NSString *)name {
    _entityInformationByName[name] = information;
}

#pragma mark - Properties
- (void)setEntityInformationByName:(NSDictionary *)entityInformationByName {
    _entityInformationByName = [entityInformationByName mutableCopy];
}

- (NSDictionary *)entityInformationByName {
    return [_entityInformationByName copy];
}

- (id)representationForSerialization {
    NSMutableDictionary *result = [NSMutableDictionary new];
    for(NSString *entityName in _entityInformationByName) {
        CDEEntityAutosaveInformation *information = _entityInformationByName[entityName];
//        result[entityName] = information.dictionaryRepresentation;
        [result addEntriesFromDictionary:information.dictionaryRepresentation];
    }
    return result;
}

#pragma mark - Equality
- (BOOL)isEqualToAutosaveInformation:(CDEAutosaveInformation *)autosaveInformation {
    if(autosaveInformation == nil) {
        return NO;
    }
    
    if(autosaveInformation == self) {
        return YES;
    }
    
    NSDictionary *otherInformationByName = autosaveInformation.entityInformationByName;
    if(otherInformationByName.count != self.entityInformationByName.count) {
        return NO;
    }
    
    // Compare each value in entityInformationByName
    
    for(NSString *entityName in _entityInformationByName) {
        CDEEntityAutosaveInformation *entityInformation = [self informationForEntityNamed:entityName];
        CDEEntityAutosaveInformation *otherEntityInformation = [autosaveInformation informationForEntityNamed:entityName];
        if(otherEntityInformation == nil) {
            return NO;
        }
        BOOL entityInformationEqual = [entityInformation isEqualToEntityAutosaveInformation:otherEntityInformation];
        if(entityInformationEqual == NO) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Helper
// dictionaryRepresentation: never nil
- (void)_setupWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation {
    NSParameterAssert(dictionaryRepresentation);
    NSParameterAssert(_entityInformationByName);
    [dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSString *entityName, NSArray *primitiveItems, BOOL *stop) {
        NSMutableArray *items = [NSMutableArray new];
        for(NSDictionary *primitiveItem in primitiveItems) {
            CDEEntityAutosaveInformationItem *item = [CDEEntityAutosaveInformationItem newWithProperties:primitiveItem];
            [items addObject:item];
        }
        CDEEntityAutosaveInformation *information = [CDEEntityAutosaveInformation newWithEntityName:entityName items:items];
        _entityInformationByName[entityName] = information;
    }];
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", [super description], _entityInformationByName];
}


@end
