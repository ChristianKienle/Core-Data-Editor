#import "NSEntityDescription+CDEAdditions.h"

@implementation NSEntityDescription (CDEAdditions)

#pragma mark - Convenience
- (NSArray *)supportedAttributes_cde {
    NSMutableArray *result = [NSMutableArray new];
    for(NSAttributeDescription *attribute in [[self attributesByName] allValues]) {
        // Ignore transient properties
        if(attribute.isTransient) {
            continue;
        }
        if(!attribute.isSupportedAttribute_cde) {
            continue;
        }

        [result addObject:attribute];
    }
    return result;
}


- (NSArray *)sortedToOneRelationships_cde {
    NSMutableArray *result = [NSMutableArray new];
    [self.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(id key, NSRelationshipDescription *relation, BOOL *stop) {
        if(relation.isToMany) {
            return;
        }
        [result addObject:relation];
    }];
    return [result sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSRelationshipDescription *relationA, NSRelationshipDescription *relationB) {
        return [relationA.name localizedStandardCompare:relationB.name];
    }];
}

- (NSArray *)sortedRelationships_cde {
    return [self.relationshipsByName.allValues sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSRelationshipDescription *relationA, NSRelationshipDescription *relationB) {
        return [relationA.name localizedStandardCompare:relationB.name];
    }];
}

- (NSString *)nameForDisplay_cde {
    return [self.name humanReadableStringAccordingToUserDefaults_cde];
}

#pragma mark - CSV

// This method filters out any non supported property names and also respects the sorting of propertyNames
- (NSArray *)CSVValuesForEachManagedObjectInArray:(NSArray *)objects forPropertyNames:(NSArray *)propertyNames includeHeaderValues_cde:(BOOL)includeHeaderValues {
    NSParameterAssert(objects);
    NSParameterAssert(propertyNames);

    NSMutableArray *supportedAttributeNames = [NSMutableArray new];
    for(NSString *propertyName in propertyNames) {
        if([propertyName isEqualToString:@"objectID"]) {
            [supportedAttributeNames addObject:propertyName];
            continue;
        }
        NSAttributeDescription *attribute = self.attributesByName[propertyName];
        if(attribute == nil) {
            continue;
        }
        if(!attribute.isSupportedAttribute_cde || !attribute.isSupportedCSVAttribute_cde) {
            continue;
        }
        [supportedAttributeNames addObject:attribute.name];
    }

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:objects.count + 1];

    if(includeHeaderValues) {
        [result addObject:supportedAttributeNames];
    }

    for(NSManagedObject *object in objects) {
        NSAssert([object.entity isKindOfEntity:self], @"Entity mismatch");
        NSArray *values = [object CSVValuesForAttributeNames_cde:supportedAttributeNames];
        [result addObject:values];
    }

    return result;
}

- (NSArray *)supportedCSVAttributes_cde {
    NSMutableArray *result = [NSMutableArray new];
    for(NSAttributeDescription *attribute in self.supportedAttributes_cde) {
        if(attribute.isSupportedCSVAttribute_cde) {
            [result addObject:attribute];
        }
    }
    return result;
}

#pragma mark - UI
- (NSImage *)icon_cde {
    return [NSImage imageNamed:@"entity-icon-small"];
}

@end
