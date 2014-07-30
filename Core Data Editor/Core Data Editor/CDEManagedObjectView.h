#import <Cocoa/Cocoa.h>
#import "CDEAttributeViewControllerDelegate.h"

@class CDEGenerateThumbnailsController;
@interface CDEManagedObjectView : NSView <CDEAttributeViewControllerDelegate>

#pragma mark Properties
@property (retain) NSManagedObject *managedObject;

#pragma mark Keys, Contexts
+ (NSString *)managedObjectKey;

#pragma mark Actions
- (void)refresh;

#pragma mark - UI
- (void)updateDisplayedNames;

@end
