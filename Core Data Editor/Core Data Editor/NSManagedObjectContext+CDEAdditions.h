#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (CDEAdditions)

#pragma mark - Make a Managed Object Valid
- (void)makeManagedObjectValid:(NSManagedObject *)managedObject;

@end
