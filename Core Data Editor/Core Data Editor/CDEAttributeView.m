#import "CDEAttributeView.h"

@implementation CDEAttributeView

- (BOOL)canBecomeKeyView {
//    NSLog(@"%p - %@", self, NSStringFromSelector(_cmd));
    return YES;
}

- (BOOL)acceptsFirstResponder {
//    NSLog(@"%p - %@", self, NSStringFromSelector(_cmd));
    return YES;
}

- (BOOL)becomeFirstResponder {
//    NSLog(@"%p - %@", self, NSStringFromSelector(_cmd));
    NSView *nextKeyView = self.nextKeyView;
    NSView *scrollToView = nextKeyView.superview;
    NSRect rect = scrollToView.frame;
//    NSString *rectString = NSStringFromRect(rect);
//    NSLog(@"scroll: %@", rectString);
    [self.enclosingScrollView.documentView scrollRectToVisible:rect];
    [self.window makeFirstResponder:nextKeyView];
    
    return YES;
}

- (BOOL)resignFirstResponder {
//    NSLog(@"%p - %@", self, NSStringFromSelector(_cmd));
    return YES;
}

//- (void)drawRect:(NSRect)dirtyRect {
//    [[NSColor lightGrayColor] set];
//    NSRectFill(self.bounds);
//    [[NSColor blackColor] setStroke];
//    NSFrameRect(self.bounds);
//}

@end
