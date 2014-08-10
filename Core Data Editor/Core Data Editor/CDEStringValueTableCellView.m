#import "CDEStringValueTableCellView.h"

@interface CDEStringValueTableCellView ()

@property (nonatomic, weak) IBOutlet NSButton *actionButton;

@end

@implementation CDEStringValueTableCellView

#pragma mark - NSTableCellView
- (void)setObjectValue:(id)objectValue {
    id resultingObjectValue = nil;
    
    if(objectValue == [NSNull null]) {
        resultingObjectValue = nil;
        [self.textField.cell setPlaceholderString:@"nil"];
    }
    else {
        [self.textField.cell setPlaceholderString:nil];
        resultingObjectValue = objectValue;
    }
    [super setObjectValue:resultingObjectValue];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)style {
    [super setBackgroundStyle:style];
    NSView *superView = self.superview;
    if(superView == nil) {
        [self.actionButton setHidden:NO];
        return;
    }
    
    if([superView respondsToSelector:@selector(isSelected)] == NO) {
        [self.actionButton setHidden:NO];
        return;
    }
    
    BOOL isSelected = [(NSTableRowView *)superView isSelected];
    [self.actionButton setHidden:!isSelected];
}

@end
