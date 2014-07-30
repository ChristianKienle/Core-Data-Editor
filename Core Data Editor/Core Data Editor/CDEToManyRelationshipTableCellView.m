
#import "CDEToManyRelationshipTableCellView.h"
#import "CDEManagedObjectsRequest.h"

@interface CDEToManyRelationshipTableCellView ()

@property (nonatomic, weak) IBOutlet NSButton *countButton;

@end

@implementation CDEToManyRelationshipTableCellView

- (void)awakeFromNib {
    // We want it to appear "inline"
    [[self.countButton cell] setBezelStyle:NSInlineBezelStyle];
}
- (void)setObjectValue:(id)objectValue {
    [super setObjectValue:objectValue];
    [[self.countButton cell] setHighlightsBy:0];
    [self performCustomLayout];
}

- (void)viewWillDraw {
    [super viewWillDraw];
    [self performCustomLayout];
}

- (void)performCustomLayout {

    CDEManagedObjectsRequest *request = self.objectValue;
    id objects = [request.managedObject valueForKey:request.relationshipDescription.name];

    [self.countButton setTitle:[NSString stringWithFormat:@"%li", objects == nil ? 0 :[objects count]  ]];

    [self.countButton sizeToFit];
    
    NSRect textFrame = NSZeroRect;
    NSRect buttonFrame = self.countButton.frame;
    buttonFrame.origin.x = NSMidX(self.bounds) - (0.5 * NSWidth(buttonFrame));
    buttonFrame.origin.y = NSMidY(self.bounds) - (0.5 * NSHeight(buttonFrame));

    self.countButton.frame = buttonFrame;
    textFrame.size.width = NSMinX(buttonFrame) - NSMinX(textFrame);
    self.textField.frame = textFrame;
}

@end
