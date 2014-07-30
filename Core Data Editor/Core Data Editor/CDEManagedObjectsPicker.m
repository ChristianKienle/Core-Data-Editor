#import "CDEManagedObjectsPicker.h"
#import "CDEManagedObjectsPickerViewController.h"

@interface CDEManagedObjectsPicker () <NSPopoverDelegate>

#pragma mark - Properties
@property (nonatomic, strong) CDEManagedObjectsPickerViewController *viewController;
@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, copy) CDEManagedObjectsPickerCompletionHandler completionHandler;
@end

@implementation CDEManagedObjectsPicker

#pragma mark - Creating
- (id)init {
    self = [super init];
    if(self) {
    }
    return self;
}

#pragma mark - Show the Picker
- (void)displayObjectsOfEntityDescription:(NSEntityDescription *)entityDescription
                   selectedManagedObjects:(id)selectedManagedObjects
                     managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  allowsMultipleSelection:(BOOL)allowsMultipleSelection
                       showRelativeToRect:(NSRect)positioningRect
                                   ofView:(NSView *)positioningView
                        completionHandler:(CDEManagedObjectsPickerCompletionHandler)completionHandler {
    NSParameterAssert(self.popover == nil);
    NSParameterAssert(self.viewController == nil);
    NSParameterAssert(entityDescription);
    NSParameterAssert(managedObjectContext);
    NSParameterAssert(positioningView);
    
    self.completionHandler = completionHandler;
    [self _createAndSetPopoverAndViewController];
    [self.viewController setEntityDescription:entityDescription
                       selectedManagedObjects:selectedManagedObjects
                         managedObjectContext:managedObjectContext
                      allowsMultipleSelection:allowsMultipleSelection];
    
    [self.popover showRelativeToRect:positioningRect ofView:positioningView preferredEdge:NSMaxXEdge];
}

- (void)_createAndSetPopoverAndViewController {
    self.popover = [NSPopover new];
    self.popover.behavior = NSPopoverBehaviorTransient;
    
    // so we can be notified when the popover appears or closes
    self.popover.delegate = self;
    
    self.viewController = [[CDEManagedObjectsPickerViewController alloc] initWithNibName:@"CDEManagedObjectsPickerViewController" bundle:nil];
    self.popover.contentViewController = self.viewController;
}

#pragma mark - NSPopoverDelegate
- (void)popoverDidClose:(NSNotification *)notification {
    self.completionHandler ? self.completionHandler(self.viewController.selectedManagedObjects) : nil;
    self.completionHandler = nil;
    NSLog(@"selected objects: %@", [self.viewController.selectedManagedObjects valueForKey:@"objectID"]);
    self.viewController = nil;
    self.popover.contentViewController = nil;
    self.popover = nil;
}

@end
