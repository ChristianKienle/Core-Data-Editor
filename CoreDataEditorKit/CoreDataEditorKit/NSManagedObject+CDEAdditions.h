#import <CoreData/CoreData.h>

@interface NSManagedObject (CDEAdditions)

@property (nullable, nonatomic, readonly) NSArray<NSError*> *validationErrors_cde;
- (NSArray<NSAttributeDescription*>*)invalidAttributes;
@end

