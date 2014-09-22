#import <CoreData/CoreData.h>

@interface NSEntityDescription (CDEAdditions)

#pragma mark - Convenience
- (NSArray *)supportedAttributes_cde;
- (NSArray *)toManyRelationships_cde;
- (NSDictionary *)toManyRelationshipsByName_cde;
- (NSArray *)sortedToManyRelationshipNames_cde;
- (NSArray *)sortedToManyRelationships_cde;
- (NSArray *)sortedToOneRelationships_cde;
- (NSArray *)sortedRelationships_cde;
- (NSAttributeDescription *)attributeDescriptionForName_cde:(NSString *)attributeName;


#pragma mark - UI
- (UIImage *)icon_cde;

@end
