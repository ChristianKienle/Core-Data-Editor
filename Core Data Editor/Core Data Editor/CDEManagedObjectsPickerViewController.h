#import <Cocoa/Cocoa.h>

@interface CDEManagedObjectsPickerViewController : NSViewController

#pragma mark - Displaying Stuff
- (void)setEntityDescription:(NSEntityDescription *)entityDescription
      selectedManagedObjects:(id)selectedManagedObjects // NSSet or NSOrderedSet
        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
     allowsMultipleSelection:(BOOL)allowsMultipleSelection;

#pragma mark - Properties
@property (nonatomic, copy, readonly) NSSet *selectedManagedObjects;

@end
