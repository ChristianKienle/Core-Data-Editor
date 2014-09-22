#import "NSAttributeDescription+CDEAdditions.h"

#pragma mark - Working with Attribute Types
BOOL CDEIsStringAttributeType(NSAttributeType type) {
    return (type == NSStringAttributeType);
}

BOOL CDEIsFloatingPointAttributeType(NSAttributeType type) {
    return (type == NSDoubleAttributeType ||
            type == NSFloatAttributeType ||
            type == NSDecimalAttributeType);
}

BOOL CDEIsIntegerAttributeType(NSAttributeType type) {
    return (type == NSInteger16AttributeType ||
            type == NSInteger32AttributeType ||
            type == NSInteger64AttributeType);
}

@implementation NSAttributeDescription (CDEAdditions)

#pragma mark - Concenience
- (BOOL)isSupportedAttribute_cde {
  return YES;
}

- (BOOL)isAttributeWithFloatingPointCharacteristics_cde {
    NSAttributeType type = self.attributeType;
    return (type == NSDoubleAttributeType || type == NSFloatAttributeType || type == NSDecimalAttributeType);
}

- (BOOL)isAttributeWithIntegerCharacteristics_cde {
    NSAttributeType type = self.attributeType;
    return [[self class] attributeTypeHasIntegerCharacteristics_cde:type];
}

+ (BOOL)attributeTypeHasIntegerCharacteristics_cde:(NSAttributeType)type {
    return type == NSInteger16AttributeType || type == NSInteger32AttributeType || type == NSInteger64AttributeType;
}

- (NSSortDescriptor *)sortDescriptorPrototype_cde {
    NSAttributeType type = self.attributeType;
    
    if(type == NSBinaryDataAttributeType || type == NSTransformableAttributeType) {
        return [NSSortDescriptor sortDescriptorWithKey:self.name ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
            if([obj1 length] > [obj2 length]) {
                return NSOrderedDescending;
            }
            if([obj1 length] < [obj2 length]) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
            
        }];
    }
    
    SEL selector = @selector(compare:);

    if(type == NSStringAttributeType) {
        selector = @selector(localizedStandardCompare:);
    }
    
    return [NSSortDescriptor sortDescriptorWithKey:self.name ascending:NO selector:selector];
}

+ (NSPredicateOperatorType)predicateOperatorTypeForAttributeType_cde:(NSAttributeType)type {
    if(type == NSStringAttributeType) {
        return NSContainsPredicateOperatorType;
    }
    if([self attributeTypeHasIntegerCharacteristics_cde:type]) {
        return NSEqualToPredicateOperatorType;
    }
    return NSEqualToPredicateOperatorType;
}

#pragma mark - CSV
- (BOOL)isSupportedCSVAttribute_cde {
    NSAttributeType type = self.attributeType;
    return [[self class] isSupportedCSVAttributeType_cde:type];
}

+ (BOOL)isSupportedCSVAttributeType_cde:(NSAttributeType)type {
    return CDEIsFloatingPointAttributeType(type) ||
    CDEIsIntegerAttributeType(type) ||
    CDEIsStringAttributeType(type) ||
    type == NSBooleanAttributeType ||
    type == NSDateAttributeType;
}

#pragma mark - NSPropertyDescription Additions
- (BOOL)isAttributeDescription_cde {
    return YES;
}

- (BOOL)isRelationshipDescription_cde {
    return NO;
}


@end
