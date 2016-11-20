#import <CoreData/CoreData.h>

@interface NSManagedObject (CDEAdditions)

@property (nonatomic, readonly) NSArray<NSError*> *validationErrors_cde;

#pragma mark - CSV
// Special Consideration: attributeNames can contain @"objectID" although this is not an official attribute.
//                        If it does then each objectID value is retrieved and added to the resulting array
//                        as if it were a normal attribute.
// This method does not do any further checks regarding attributeNames.
- (NSArray<NSString*> *)CSVValuesForAttributeNames_cde:(NSArray<NSString*> *)attributeNames;

#pragma mark - Creating
+ (instancetype)newManagedObjectWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context makeInsertedObjectValid_cde:(BOOL)makeInsertedObjectValid;
+ (instancetype)newManagedObjectWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext_cde:(NSManagedObjectContext *)context;

@end

