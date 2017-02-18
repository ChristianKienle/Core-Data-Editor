#import <CoreData/CoreData.h>

@interface NSEntityDescription (CDEAdditions)

#pragma mark - Convenience
- (NSArray<NSAttributeDescription*> *)supportedAttributes_cde;
- (NSArray<NSRelationshipDescription*> *)toManyRelationships_cde;
- (NSDictionary<NSString*, NSRelationshipDescription*>*)toManyRelationshipsByName_cde;
- (NSArray<NSString*> *)sortedToManyRelationshipNames_cde;
- (NSArray<NSRelationshipDescription*> *)sortedToManyRelationships_cde;
- (NSArray<NSRelationshipDescription*> *)sortedToOneRelationships_cde;
- (NSArray<NSRelationshipDescription*> *)sortedRelationships_cde;
- (NSAttributeDescription *)attributeDescriptionForName_cde:(NSString *)attributeName;

#pragma mark - UI
- (UIImage *)icon_cde;

@end
