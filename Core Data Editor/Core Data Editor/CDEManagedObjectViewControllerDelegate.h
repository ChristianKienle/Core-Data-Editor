#import <Foundation/Foundation.h>

@class CDEManagedObjectViewController;

@protocol CDEManagedObjectViewControllerDelegate <NSObject>

- (void)managedObjectViewControllerDidAddOrRemoveManagedObject:(CDEManagedObjectViewController *)managedObjectViewController;

@end
