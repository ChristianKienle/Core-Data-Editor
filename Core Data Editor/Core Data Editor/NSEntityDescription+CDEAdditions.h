#import <CoreData/CoreData.h>

@interface NSEntityDescription (CDEAdditions)

#pragma mark - Convenience
- (NSArray<NSAttributeDescription*> *)supportedAttributes_cde;
- (NSArray<NSRelationshipDescription*> *)sortedToOneRelationships_cde;
- (NSArray<NSRelationshipDescription*> *)sortedRelationships_cde;
@property (nonatomic, readonly) NSString *nameForDisplay_cde;

#pragma mark - CSV

// This method filters out any non supported property names and also respects the sorting of propertyNames
- (NSArray<NSArray<NSString*>*> *)CSVValuesForEachManagedObjectInArray:(NSArray *)objects forPropertyNames:(NSArray *)propertyNames includeHeaderValues_cde:(BOOL)includeHeaderValues;
- (NSArray<NSAttributeDescription*> *)supportedCSVAttributes_cde;

#pragma mark - UI
- (NSImage *)icon_cde;

@end
