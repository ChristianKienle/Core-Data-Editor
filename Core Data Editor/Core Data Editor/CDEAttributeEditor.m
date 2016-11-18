#import "CDEAttributeEditor.h"
#import "CDEAttributeEditorViewController.h"
#import "CDEAttributeEditorWindowController.h"

@interface CDEAttributeEditor ()

#pragma mark - Globals

#pragma mark - Properties
@property (nonatomic, strong) CDEAttributeEditorViewController *viewController;
@property (nonatomic, strong) CDEAttributeEditorWindowController *windowController;
@property (nonatomic, copy) CDEAttributeEditorCompletionHandler completionHandler;


@end

@implementation CDEAttributeEditor

#pragma mark - Showing the Editor
- (void)showEditorForManagedObject:(NSManagedObject *)managedObject
              attributeDescription:(NSAttributeDescription *)attributeDescription
                showRelativeToRect:(NSRect)positioningRect
                            ofView:(NSView *)positioningView
                 completionHandler:(CDEAttributeEditorCompletionHandler)completionHandler {
    NSParameterAssert(managedObject);
    NSParameterAssert(attributeDescription);
    NSParameterAssert(positioningView);
    
    self.completionHandler = completionHandler;
    self.windowController = [[CDEAttributeEditorWindowController alloc] initWithManagedObject:managedObject attributeDescription:attributeDescription];
    [self.windowController window];
  
  [positioningView.window beginSheet:self.windowController.window completionHandler:^(NSModalResponse returnCode) {
    self.viewController = nil;
    self.windowController = nil;
    self.completionHandler ? self.completionHandler() : nil;
    self.completionHandler = nil;
  }];
}

#pragma mark - Closing the Editor
- (BOOL)isShown {
    return (self.windowController != nil);
}

- (void)close {
  [self.windowController.window.sheetParent endSheet:self.windowController.window returnCode:NSModalResponseOK];
}

@end
