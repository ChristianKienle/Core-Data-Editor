#import "NSEntityDescription+CDEAdditions.h"
#import "NSAttributeDescription+CDEAdditions.h"

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

- (NSArray *)toManyRelationships_cde {
    NSMutableArray *result = [NSMutableArray new];
    [self.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(id key, NSRelationshipDescription *relation, BOOL *stop) {
        if(relation.isToMany == NO) {
            return;
        }
        [result addObject:relation];
    }];
    return result;
}

- (NSDictionary *)toManyRelationshipsByName_cde {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [self.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSRelationshipDescription *relation, BOOL *stop) {
        if(relation.isToMany == NO) {
            return;
        }
        result[name] = relation;
    }];
    return result;
}

- (NSArray *)sortedToManyRelationshipNames_cde {
    NSArray *unsorted = [[self toManyRelationshipsByName_cde] allKeys];
    return [unsorted sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSString *relationA, NSString *relationB) {
        return [relationA localizedStandardCompare:relationB];
    }];
}

- (NSArray *)sortedToManyRelationships_cde {
    NSMutableArray *result = [NSMutableArray new];
    [self.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(id key, NSRelationshipDescription *relation, BOOL *stop) {
        if(relation.isToMany == NO) {
            return;
        }
        [result addObject:relation];
    }];
    return [result sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSRelationshipDescription *relationA, NSRelationshipDescription *relationB) {
        return [relationA.name localizedStandardCompare:relationB.name];
    }];
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

//- (NSString *)nameForDisplay_cde {
//    return [self.name humanReadableStringAccordingToUserDefaults_cde];
//}

- (NSAttributeDescription *)attributeDescriptionForName_cde:(NSString *)attributeName {
    NSParameterAssert(attributeName);
    return self.attributesByName[attributeName];
}

//#pragma mark - CSV
//// returns an array of arrays
//- (NSArray *)CSVValuesForEachManagedObjectInArray_cde:(NSArray *)objects {
//    NSParameterAssert(objects);
//    NSArray *supportedAttributes = self.supportedCSVAttributes_cde;
//    NSArray *supportedAttributeNames = [supportedAttributes valueForKey:@"name"];
//    return [self CSVValuesForEachManagedObjectInArray:objects forPropertyNames:supportedAttributeNames includeHeaderValues_cde:NO];
//}
//
//// This method filters out any non supported property names and also respects the sorting of propertyNames
//- (NSArray *)CSVValuesForEachManagedObjectInArray:(NSArray *)objects forPropertyNames:(NSArray *)propertyNames includeHeaderValues_cde:(BOOL)includeHeaderValues {
//    NSParameterAssert(objects);
//    NSParameterAssert(propertyNames);
//    
//    NSMutableArray *supportedAttributeNames = [NSMutableArray new];
//    for(NSString *propertyName in propertyNames) {
//        if([propertyName isEqualToString:@"objectID"]) {
//            [supportedAttributeNames addObject:propertyName];
//            continue;
//        }
//        NSAttributeDescription *attribute = self.attributesByName[propertyName];
//        if(attribute == nil) {
//            continue;
//        }
//        if(!attribute.isSupportedAttribute_cde || !attribute.isSupportedCSVAttribute_cde) {
//            continue;
//        }
//        [supportedAttributeNames addObject:attribute.name];
//    }
//    
//    NSMutableArray *result = [NSMutableArray arrayWithCapacity:objects.count + 1];
//
//    if(includeHeaderValues) {
//        [result addObject:supportedAttributeNames];
//    }
//    
//    for(NSManagedObject *object in objects) {
//        NSAssert([object.entity isKindOfEntity:self], @"Entity mismatch");
//        NSArray *values = [object CSVValuesForAttributeNames_cde:supportedAttributeNames];
//        [result addObject:values];
//    }
//    
//    return result;
//}
//
//- (NSArray *)supportedCSVAttributes_cde {
//    NSMutableArray *result = [NSMutableArray new];
//    for(NSAttributeDescription *attribute in self.supportedAttributes_cde) {
//        if(attribute.isSupportedCSVAttribute_cde) {
//            [result addObject:attribute];
//        }
//    }
//    return result;
//}

#pragma mark - UI
- (UIImage *)icon_cde {
  return nil;
//  return [UIImage imageNamed:@"entity-icon-small"];
}

@end
