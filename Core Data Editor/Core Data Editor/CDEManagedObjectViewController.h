#import <Cocoa/Cocoa.h>
#import "CMKViewController.h"

@class CDEManagedObjectView;
@class CDEManagedObjectsRequest;
@protocol CDEManagedObjectViewControllerDelegate;

@interface CDEManagedObjectViewController : CMKViewController

// represented Object is CDEManagedObjectsRequest

#pragma mark Properties
@property (nonatomic, strong) CDEManagedObjectsRequest *request; // sets and gets representedObject
@property (nonatomic, weak) id<CDEManagedObjectViewControllerDelegate> delegate;

#pragma mark - UI
- (void)updateDisplayedNames;

@end
