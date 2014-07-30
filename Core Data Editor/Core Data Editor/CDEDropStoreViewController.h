#import <Cocoa/Cocoa.h>

@class CDEDropZoneView;
@class CDEPathActionLabelController;
@protocol CDEDropStoreViewControllerDelegate;

@interface CDEDropStoreViewController : NSViewController

#pragma mark Properties
@property (nonatomic, weak) id<CDEDropStoreViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet CDEDropZoneView *dropZoneView;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, copy) NSURL *validStoreURL;
@property (nonatomic, getter=isEditing) BOOL editing;
@property (nonatomic, weak) IBOutlet NSTextField *infoTextField;
@property (nonatomic, weak) IBOutlet NSTextField *pathTextField;
@property (nonatomic, weak) IBOutlet CDEPathActionLabelController *pathActionLabelController;

@end
