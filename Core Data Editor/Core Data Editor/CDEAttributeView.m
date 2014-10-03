#import "CDEAttributeView.h"

@implementation CDEAttributeView

- (BOOL)canBecomeKeyView {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    NSView *nextKeyView = self.nextKeyView;
    NSView *scrollToView = nextKeyView.superview;
    NSRect rect = scrollToView.frame;
    [self.enclosingScrollView.documentView scrollRectToVisible:rect];
    [self.window makeFirstResponder:nextKeyView];
    
    return YES;
}

- (BOOL)resignFirstResponder {
    return YES;
}

@end
