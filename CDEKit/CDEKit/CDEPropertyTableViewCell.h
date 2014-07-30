#import <UIKit/UIKit.h>

@interface CDEPropertyTableViewCell : UITableViewCell

#pragma mark - Properties
@property (nonatomic, strong) NSPropertyDescription *propertyDescription;
@property (nonatomic, strong) NSManagedObject *managedObject;

#pragma mark - UI
// propertyDescription and managedObject have to be set before calling this method
- (void)updateUI;

@end
