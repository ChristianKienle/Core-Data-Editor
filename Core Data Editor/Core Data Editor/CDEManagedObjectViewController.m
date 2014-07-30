#import "CDEManagedObjectViewController.h"
#import "CDEManagedObjectViewControllerDelegate.h"

#import "CDEManagedObjectView.h"
#import "CDEBinaryDataToSizeValueTransformer.h"
#import "CDEManagedObjectsRequest.h"
#import "CDEManagedObjectsPicker.h"

@interface CDEManagedObjectViewController ()

#pragma mark - Properties
@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, weak) IBOutlet NSButton *addButton;
@property (nonatomic, weak) IBOutlet NSButton *removeButton;
@property (nonatomic, weak) IBOutlet NSMenuItem *createManagedObjectMenuItem;
@property (nonatomic, weak) IBOutlet CDEManagedObjectView *managedObjectView;
@property (nonatomic, strong) CDEManagedObjectsPicker *managedObjectsPicker;

@end


@implementation CDEManagedObjectViewController

#pragma mark NSObject
+ (void)initialize {
   if(self == [CDEManagedObjectViewController class]) {
      NSString *binaryDataToSizeTransformerName = [CDEBinaryDataToSizeValueTransformer name];
      if([[NSValueTransformer valueTransformerNames] containsObject:binaryDataToSizeTransformerName] == YES) {
         return;
      }
      [NSValueTransformer setValueTransformer:[CDEBinaryDataToSizeValueTransformer new] forName:binaryDataToSizeTransformerName];
   }
}

#pragma mark CMKViewController
- (NSString *)nibName {
    return @"CDEManagedObjectView";
}

- (void)loadView {
    [super loadView];
    self.managedObjectsPicker = [CDEManagedObjectsPicker new];
}

#pragma mark - UI
- (void)updateDisplayedNames {
    [self.managedObjectView updateDisplayedNames];
}

#pragma mark - Displaying Information
- (void)_showManagedObjectView {
    [self.tabView selectTabViewItemAtIndex:0];
}

- (void)_showNoRelatedObjectView {
    [self.tabView selectTabViewItemAtIndex:1];
}

- (void)_updateUIWithCurrentRequest {
    [self.managedObjectView setManagedObject:self.request.relatedObject];
    [[self managedObjectView] refresh];
    [self updateAddAndRemoveButtons];
    if(self.request.relatedObject == nil) {
        [self _showNoRelatedObjectView];
    } else {
        [self _showManagedObjectView];
    }
}

#pragma mark - Working with the Delegate
- (void)managedObjectViewControllerDidAddOrRemoveManagedObject {
    if(self.delegate == nil) {
        return;
    }
    if([self.delegate respondsToSelector:@selector(managedObjectViewControllerDidAddOrRemoveManagedObject:)] == NO) {
        return;
    }
    [self.delegate managedObjectViewControllerDidAddOrRemoveManagedObject:self];
}

#pragma mark - Actions
- (IBAction)add:(id)sender {
    NSEntityDescription *entity = [[self request] entityDescription];
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:entity.name
                                                                   inManagedObjectContext:[[self request] managedObjectContext]];
    [self.request.managedObject setValue:managedObject forKey:self.request.relationshipDescription.name];
    [self _updateUIWithCurrentRequest];
    [self managedObjectViewControllerDidAddOrRemoveManagedObject];
}

- (IBAction)remove:(id)sender {
    NSManagedObject *object = self.request.relatedObject;
    [self.request.managedObject setValue:nil forKey:self.request.relationshipDescription.name];
    [self.request.managedObjectContext deleteObject:object];
    [self _updateUIWithCurrentRequest];
    [self managedObjectViewControllerDidAddOrRemoveManagedObject];
}

- (void)updateAddAndRemoveButtons {
    [self.createManagedObjectMenuItem setEnabled:[self request] != nil && [[self request] relatedObject] == nil];
    [self.removeButton setEnabled:[self request] != nil && [[self request] relatedObject] != nil];
}

- (IBAction)showManagedObjectsPicker:(id)sender {
    NSSet *selectedManagedObjects = nil;
    if(self.request.relatedObject != nil) {
        selectedManagedObjects = [NSSet setWithObject:self.request.relatedObject];
    }
    [self.managedObjectsPicker displayObjectsOfEntityDescription:self.request.entityDescription
                                          selectedManagedObjects:selectedManagedObjects
                                            managedObjectContext:self.request.managedObjectContext
                                         allowsMultipleSelection:NO
                                              showRelativeToRect:self.addButton.bounds
                                                          ofView:self.addButton
                                               completionHandler:^(NSSet *pickedObjects) {
        [self.request.managedObject setValue:pickedObjects.anyObject forKey:self.request.relationshipDescription.name];
        [self _updateUIWithCurrentRequest];
        [self managedObjectViewControllerDidAddOrRemoveManagedObject];
    }];
}

#pragma mark Properties
- (CDEManagedObjectsRequest *)request {
    return self.representedObject;
}

- (void)setRequest:(CDEManagedObjectsRequest *)request {
    [self setRepresentedObject:request];
}

- (void)setRepresentedObject:(id)newObject {
    [super setRepresentedObject:newObject];
    
    [[self managedObjectView] setManagedObject:self.request.relatedObject];
    [[self managedObjectView] refresh];
    
    if(self.request != nil && self.request.relatedObject != nil) {
        [self _showManagedObjectView];
    } else {
        [self _showNoRelatedObjectView];
    }
    [self updateAddAndRemoveButtons];
}

@end
