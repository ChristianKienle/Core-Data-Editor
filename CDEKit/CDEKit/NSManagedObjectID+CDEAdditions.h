#import <CoreData/CoreData.h>

@interface NSManagedObjectID (CDEAdditions)
- (NSString *)humanReadableRepresentationByHidingEntityName_cde:(BOOL)hideEntityName;
@end
