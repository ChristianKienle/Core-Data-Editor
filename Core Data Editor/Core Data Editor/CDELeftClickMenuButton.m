#import "CDELeftClickMenuButton.h"

@implementation CDELeftClickMenuButton

- (void)mouseDown:(NSEvent *)theEvent {
    if(self.menu == nil) {
        [super mouseDown:theEvent];
        return;
    }
    if(self.isEnabled == NO) {
        return;
    }
    [self setState:NSOnState];
    [self highlight:YES];
    
    if([self menu]) {
        [NSMenu popUpContextMenu:[self menu] withEvent:theEvent forView:self];
    }
    
    [self setState:NSOffState];
    [self highlight:NO];
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    return nil;
}

@end
