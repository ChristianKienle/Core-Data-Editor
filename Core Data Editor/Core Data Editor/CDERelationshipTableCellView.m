#import "CDERelationshipTableCellView.h"
#import "CDERelationshipsViewControllerItem.h"

@interface CDERelationshipTableCellView ()

#pragma mark - Properties
@property (nonatomic, weak) IBOutlet NSButton *badgeButton;

@end

@implementation CDERelationshipTableCellView

#pragma mark - Properties
- (void)setBadgeValue:(NSInteger)badgeValue {
    _badgeValue = badgeValue;
    [self.badgeButton setTitle:[NSString stringWithFormat:@"%li", self.badgeValue]];
    [self performCustomLayout];
}

- (void)setObjectValue:(id)objectValue {
    [super setObjectValue:objectValue];
    if(objectValue != nil) {
        self.badgeValue = [(CDERelationshipsViewControllerItem *)self.objectValue numberOfRelatedObjects];
    }
}

#pragma mark - NSView
- (void)awakeFromNib {
    [[self.badgeButton cell] setBezelStyle:NSInlineBezelStyle];
    [[self.badgeButton cell] setHighlightsBy:0];
}

- (void)viewWillDraw {
    [super viewWillDraw];
    [self performCustomLayout];
}

- (void)performCustomLayout {
    [self.badgeButton sizeToFit];
    NSRect textFrame = self.textField.frame;
    NSRect buttonFrame = self.badgeButton.frame;
    buttonFrame.origin.x = NSWidth(self.frame) - NSWidth(buttonFrame);
    self.badgeButton.frame = buttonFrame;
    textFrame.size.width = NSMinX(buttonFrame) - NSMinX(textFrame);
    self.textField.frame = textFrame;
}

#pragma mark - UI
- (void)updateTitle {
    self.textField.stringValue = [[(CDERelationshipsViewControllerItem *)self.objectValue relationshipDescription] nameForDisplay_cde];
    [self performCustomLayout];
}

- (void)reloadBadgeValue {
    self.badgeValue = [(CDERelationshipsViewControllerItem *)self.objectValue numberOfRelatedObjects];
}

@end
