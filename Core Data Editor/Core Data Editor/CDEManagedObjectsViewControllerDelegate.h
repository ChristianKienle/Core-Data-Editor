#import <Foundation/Foundation.h>

@class CDEManagedObjectsViewController;
@class CDEManagedObjectsRequest;

@protocol CDEManagedObjectsViewControllerDelegate <NSObject>

@optional
- (void)managedObjectsViewController:(CDEManagedObjectsViewController *)managedObjectsViewController
           wantsRequestToBeDisplayed:(CDEManagedObjectsRequest *)request;

- (void)managedObjectsViewController:(CDEManagedObjectsViewController *)managedObjectsViewController
              didSelectManagedObject:(NSManagedObject *)managedObject;

- (void)managedObjectsViewControllerDidChangeContents:(CDEManagedObjectsViewController *)managedObjectsViewController;

- (void)managedObjectsViewControllerDidChangeAutosaveInformation:(CDEManagedObjectsViewController *)managedObjectsViewController;

- (void)managedObjectsViewController:(CDEManagedObjectsViewController *)managedObjectsViewController
               didSelectRelationship:(NSRelationshipDescription *)relationship
                     ofManagedObject:(NSManagedObject *)managedObject;

@end
