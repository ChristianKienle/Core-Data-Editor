#import "CDEAttributeEditorWindowController.h"
#import "CDEAttributeEditorViewController.h"

@interface CDEAttributeEditorWindowController ()

#pragma mark - Properties
@property (nonatomic, strong) CDEAttributeEditorViewController *viewController;
@property (nonatomic, weak) IBOutlet NSView *container;

@end

@implementation CDEAttributeEditorWindowController

#pragma mark - Creating
- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
                 attributeDescription:(NSAttributeDescription *)attributeDescription {
    NSParameterAssert(managedObject);
    NSParameterAssert(attributeDescription);
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    if(self) {
        self.viewController = [[CDEAttributeEditorViewController alloc] initWithManagedObject:managedObject attributeDescription:attributeDescription];
    }
    return self;
}

#pragma mark - NSWindowController
- (void)windowDidLoad {
    [super windowDidLoad];
    [self.viewController view];
    
    CGFloat containerHeightDelta = NSHeight(self.viewController.view.frame) - NSHeight(self.container.bounds); // < 0: shrink the overall size
                                                                                                               // > 0: increase the overall size

    CGFloat containerWidthDelta = NSWidth(self.viewController.view.frame) - NSWidth(self.container.bounds); // < 0: shrink the overall size
                                                                                                            // > 0: increase the overall size

    
    NSRect newFrame = self.window.frame;
    newFrame.size.height += containerHeightDelta;
    newFrame.size.width += containerWidthDelta;
    
    [self.window setFrame:newFrame display:YES];
    self.viewController.view.frame = self.container.bounds;
    [self.container addSubview:self.viewController.view];
}

- (IBAction)performClose:(id)sender {
  [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

@end
