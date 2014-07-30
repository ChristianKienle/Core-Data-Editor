#import <UIKit/UIKit.h>

@interface CDEManagedObjectsViewController : UITableViewController

#pragma mark - Properties
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSEntityDescription *entityDescription;

#pragma mark - Working with the UI
- (void)updateUI;

@end
