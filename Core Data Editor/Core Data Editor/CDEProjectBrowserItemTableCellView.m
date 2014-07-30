#import "CDEProjectBrowserItemTableCellView.h"

@interface CDEProjectBrowserItemTableCellView ()
@property (nonatomic, weak) IBOutlet NSTextField *storeLabel;
@property (nonatomic, weak) IBOutlet NSTextField *modelLabel;
@property (nonatomic, weak) IBOutlet NSTextField *storeValueLabel;
@property (nonatomic, weak) IBOutlet NSTextField *modelValueLabel;

@end

@implementation CDEProjectBrowserItemTableCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    [super setBackgroundStyle:backgroundStyle];
    [self adjustTextColorOfTextField:self.storeLabel];
    [self adjustTextColorOfTextField:self.modelLabel];
    [self adjustTextColorOfTextField:self.storeValueLabel];
    [self adjustTextColorOfTextField:self.modelValueLabel];
}

- (void)adjustTextColorOfTextField:(NSTextField *)textField {
    NSBackgroundStyle style = self.backgroundStyle;
    NSTableView *tableView = self.enclosingScrollView.documentView;
    BOOL tableViewIsFirstResponder = [tableView isEqual:[self.window firstResponder]];
    
    NSColor *color = nil;
    if(style == NSBackgroundStyleLight) {
        color = tableViewIsFirstResponder ? [NSColor lightGrayColor] : [NSColor darkGrayColor];
    } else {
        color = [NSColor whiteColor];
    }
    textField.textColor = color;
}

@end
