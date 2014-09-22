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

- (NSAttributeDescription *)attributeDescriptionForName_cde:(NSString *)attributeName {
    NSParameterAssert(attributeName);
    return self.attributesByName[attributeName];
}

#pragma mark - UI
- (UIImage *)icon_cde {
  return nil;
}

@end
