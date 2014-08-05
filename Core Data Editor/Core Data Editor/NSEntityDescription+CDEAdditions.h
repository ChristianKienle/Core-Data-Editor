#import <CoreData/CoreData.h>

@interface NSEntityDescription (CDEAdditions)

#pragma mark - Convenience
- (NSArray *)supportedAttributes_cde;
- (NSArray *)sortedToOneRelationships_cde;
- (NSArray *)sortedRelationships_cde;
@property (nonatomic, readonly) NSString *nameForDisplay_cde;

#pragma mark - CSV

// This method filters out any non supported property names and also respects the sorting of propertyNames
- (NSArray *)CSVValuesForEachManagedObjectInArray:(NSArray *)objects forPropertyNames:(NSArray *)propertyNames includeHeaderValues_cde:(BOOL)includeHeaderValues;
- (NSArray *)supportedCSVAttributes_cde;

#pragma mark - UI
- (NSImage *)icon_cde;

@end
