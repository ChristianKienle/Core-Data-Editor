#import "CDEBarView.h"

@implementation CDEBarView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSColor *topColor = [NSColor colorWithCalibratedWhite:0.975 alpha:1.000];
    NSColor *bottomColor = [NSColor colorWithCalibratedWhite:0.897 alpha:1.000];
    
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:topColor endingColor:bottomColor];
    [gradient drawInRect:self.bounds angle:-90.0];
    
    [[NSColor grayColor] setStroke];
    NSPoint topLeft = NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds));
    NSPoint topRight = NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds));
    [NSBezierPath strokeLineFromPoint:topLeft toPoint:topRight];
}

@end
