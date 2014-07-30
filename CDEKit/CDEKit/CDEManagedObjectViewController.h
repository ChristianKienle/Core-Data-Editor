#import <UIKit/UIKit.h>

@interface CDEManagedObjectViewController : UITableViewController

#pragma mark - Properties
@property (nonatomic, strong) NSManagedObject *managedObject;

#pragma mark - Working with the UI
- (void)updateUI;

@end
