#import "CDEAttributeEditorViewController.h"
#import "CDEAttributeViewController.h"

@interface CDEAttributeEditorViewController ()

#pragma mark - Properties
@property (nonatomic, strong) CDEAttributeViewController *attributeViewController;
@property (weak) IBOutlet NSView *valueContainer;
@property (weak) IBOutlet NSTextField *attributeNameLabel;

@end

@implementation CDEAttributeEditorViewController

#pragma mark - Creating
- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
                 attributeDescription:(NSAttributeDescription *)attributeDescription {
    NSParameterAssert(managedObject);
    NSParameterAssert(attributeDescription);
    
    self = [super initWithNibName:@"CDEAttributeEditorViewController" bundle:nil];
    if(self) {
        self.attributeViewController = [CDEAttributeViewController attributeViewControllerWithManagedObject:managedObject attributeDescription:attributeDescription delegate:nil];
        [self.attributeViewController view];
        NSAssert(self.attributeViewController != nil, @"Attribute view controller must be != nil");
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithManagedObject:nil attributeDescription:nil];
}

#pragma mark - NSViewController
- (void)loadView {
    [super loadView];
    self.attributeNameLabel.stringValue = [NSString stringWithFormat:@"%@:", self.attributeViewController.attributeDescription.name];
    
    // adjust self.view and self.valueContainer
    CGFloat containerHeight = NSHeight(self.valueContainer.bounds);
    CGFloat neededContainerHeight = NSHeight(self.attributeViewController.view.frame);
    CGFloat containerHeightDelta = neededContainerHeight - containerHeight; // < 0: shrink the overall size
                                                                            // > 0: increase the overall size
    
    [self.attributeViewController.attributeNameTextField sizeToFit];
    CGFloat neededWidth =  NSWidth(self.attributeViewController.view.frame) + NSWidth(self.attributeViewController.attributeNameTextField.frame);
    CGFloat containerWidthDelta = neededWidth - NSWidth(self.valueContainer.frame); // < 0: shrink the overall size
    // > 0: increase the overall size

    CGRect newContainerFrame = self.view.frame;
    newContainerFrame.size.height += containerHeightDelta;
    newContainerFrame.size.width += containerWidthDelta;

    self.view.frame = newContainerFrame;
    [self.valueContainer addSubview:self.attributeViewController.view];
    if([self.attributeViewController attributeNameTextField] != nil) {
        [self.valueContainer addSubview:[self.attributeViewController attributeNameTextField]];
    }
    [self layoutAttributeViews];
}

- (void)layoutAttributeViews {
    [self.attributeViewController.attributeNameTextField sizeToFit];

    NSView *attributeNameTextField = self.attributeViewController.attributeNameTextField;
    NSPoint nameOrigin = NSMakePoint(0,
                                     0.5 * (NSHeight([[self.attributeViewController view] frame]) - NSHeight(attributeNameTextField.frame)));
    [attributeNameTextField setFrameOrigin:nameOrigin];
    CGFloat spacing = 5.0;
    NSRect newValueFrame = NSMakeRect(NSMaxX(attributeNameTextField.frame) + spacing,
                                      0.0f,
                                      NSWidth([[self valueContainer] bounds]) - (NSWidth(attributeNameTextField.bounds) + spacing),
                                      NSHeight([[self.attributeViewController view] frame]));
    
    [[self.attributeViewController view] setFrame:newValueFrame];
}


#pragma mark - Actions
- (IBAction)cancelEditing:(id)sender {
    
}

@end
