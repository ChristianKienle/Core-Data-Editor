#import <CoreData/CoreData.h>

@interface NSManagedObject (CDEAdditions)

@property (nonnull, nonatomic, readonly) NSArray<NSError*> *validationErrors_cde;
- (NSArray<NSAttributeDescription*>* _Nonnull)invalidAttributes;
@end

