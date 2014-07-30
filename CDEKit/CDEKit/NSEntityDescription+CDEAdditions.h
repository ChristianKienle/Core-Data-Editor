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
//@property (nonatomic, readonly) NSString *nameForDisplay_cde;
- (NSAttributeDescription *)attributeDescriptionForName_cde:(NSString *)attributeName;

#pragma mark - CSV
//// returns an array of arrays
//- (NSArray *)CSVValuesForEachManagedObjectInArray_cde:(NSArray *)objects;
//
//// This method filters out any non supported property names and also respects the sorting of propertyNames
//- (NSArray *)CSVValuesForEachManagedObjectInArray:(NSArray *)objects forPropertyNames:(NSArray *)propertyNames includeHeaderValues_cde:(BOOL)includeHeaderValues;
//- (NSArray *)supportedCSVAttributes_cde;

#pragma mark - UI
- (UIImage *)icon_cde;

@end
