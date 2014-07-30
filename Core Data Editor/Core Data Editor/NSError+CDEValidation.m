#import "NSError+CDEValidation.h"

@implementation NSError (CDEValidation)

#pragma mark - Properties
- (BOOL)isSupportedValidationError_cde {
    // Let's be defensive:
    // 1. Ignore NSValidationErrorKey's that are no strings
    // 2. Ignore NSValidationErrorObject's that are no NSManagedObject's
    // 3. NSValidationErrorKey must be a supported Attribute of NSValidationErrorObject's
    // Validation Start:
    id key = self.userInfo[NSValidationKeyErrorKey];
    if([key isKindOfClass:[NSString class]] == NO) {
        NSLog(@"selected a error which is not a attribute: %@", self);
        return NO;
    }
    
    id object = self.userInfo[NSValidationObjectErrorKey];
    if([object isKindOfClass:[NSManagedObject class]] == NO) {
        NSLog(@"selected a error which is not a managed object: %@", self);
        return NO;
    }
    
    NSManagedObject *managedObject = object;
    NSString *propertyName = key;
    NSEntityDescription *entity = managedObject.entity;
    NSAttributeDescription *attribute = entity.attributesByName[propertyName];
    if(attribute == nil) {
        return NO;
    }
    
    BOOL isSupported = attribute.isSupportedAttribute_cde;
    return isSupported;
}
- (NSAttributeDescription *)invalidAttribute_cde {
    id key = self.userInfo[NSValidationKeyErrorKey];
    if([key isKindOfClass:[NSString class]] == NO) {
        NSLog(@"Error has no attribute: %@", self);
        return nil;
    }
    NSManagedObject *managedObject = self.invalidManagedObject_cde;
    if(managedObject == nil) {
        return nil;
    }
    
    NSString *propertyName = key;
    NSEntityDescription *entity = managedObject.entity;
    NSAttributeDescription *attribute = entity.attributesByName[propertyName];
    if(attribute == nil) {
        return nil;
    }
    return attribute;
}
- (NSManagedObject *)invalidManagedObject_cde {
    id object = self.userInfo[NSValidationObjectErrorKey];
    if([object isKindOfClass:[NSManagedObject class]] == NO) {
        NSLog(@"Error has no managed object: %@", self);
        return nil;
    }
    return object;
}
- (NSEntityDescription *)entityDescription_cde {
    return self.invalidManagedObject_cde.entity;
}
- (NSArray *)detailedErrors_cde {
    if(self.code != NSValidationMultipleErrorsError) {
        return @[];
    }
    NSArray *result = self.userInfo[NSDetailedErrorsKey];
    if(result == nil) {
        result = @[];
    }
    return result;
}
- (BOOL)containsDetailedErrors_cde {
    return (self.code == NSValidationMultipleErrorsError && self.userInfo[NSDetailedErrorsKey] != nil);
}

@end
