#import "CDEDateValueTableCellView.h"
#import "NSUserDefaults+CDEAdditions.h"
@interface CDEDateValueTableCellView ()

#pragma mark - Properties
@property (nonatomic, weak) IBOutlet NSButton *datePickerButton;
@end

@implementation CDEDateValueTableCellView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
    
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if(self) {
    }
    return self;
}

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
        [self.datePickerButton setHidden:NO];
        return;
    }
    
    if([superView respondsToSelector:@selector(isSelected)] == NO) {
        [self.datePickerButton setHidden:NO];
        return;
    }
    
    BOOL isSelected = [(NSTableRowView *)superView isSelected];
    [self.datePickerButton setHidden:!isSelected];
}

#pragma mark - Updating the UI
- (void)updateFormatter {
    NSDateFormatter *formatter = [[NSUserDefaults standardUserDefaults] dateFormatter_cde];    
    self.textField.formatter = formatter;
    [self.textField setNeedsDisplay:YES];
    [[self.datePickerButton cell] setBezelStyle:NSInlineBezelStyle];
    [[self.datePickerButton cell] setHighlightsBy:0];
}

@end
