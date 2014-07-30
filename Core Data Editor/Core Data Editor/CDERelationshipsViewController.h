#import <Cocoa/Cocoa.h>

@protocol CDERelationshipsViewControllerDelegate;

@interface CDERelationshipsViewController : NSViewController

#pragma mark - Properties
@property (nonatomic, strong) NSManagedObject *managedObject;
@property (nonatomic, weak) id<CDERelationshipsViewControllerDelegate> delegate;

#pragma mark - Updating the UI
- (void)updateUI;

@end
