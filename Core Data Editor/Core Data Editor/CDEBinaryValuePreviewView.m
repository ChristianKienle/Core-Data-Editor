#import "CDEBinaryValuePreviewView.h"
@interface CDEBinaryValuePreviewView ()

#pragma mark - Properties
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL mouseIsInside;

@end
@implementation CDEBinaryValuePreviewView

#pragma mark - Creating
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.mouseIsInside = NO;
        self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                    options: (NSTrackingMouseEnteredAndExited  | NSTrackingActiveInKeyWindow )
                                                      owner:self userInfo:nil];
        [self addTrackingArea:self.trackingArea];
        self.backgroundStyle = NSBackgroundStyleLight;
    }
    
    return self;
}

#pragma mark - Properties
- (void)setObjectValue:(id)objectValue {
    _objectValue = objectValue;
    [self setNeedsDisplay:YES];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    _backgroundStyle = backgroundStyle;
    [self setNeedsDisplay:YES];
}

#pragma mark - NSView
- (void)drawRect:(NSRect)dirtyRect {
    CGFloat inset = 1.0;
    NSRect boxRect = NSInsetRect(self.bounds, inset, inset);
    CGFloat cornerRadius = 2;
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:boxRect xRadius:cornerRadius yRadius:cornerRadius];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:0.5 yBy:0.5];
    [path transformUsingAffineTransform:transform];
    // Draw the objectValue if possible
    BOOL hasPreviewImage = NO;
    if([self objectValueIsValid]) {
        NSImage *image = [self imageFromObjectValue];
        if(image != nil) {
            hasPreviewImage = YES;
            [NSGraphicsContext saveGraphicsState];
            [path addClip];
            [image drawInRect:boxRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:YES hints:nil];
            [NSGraphicsContext restoreGraphicsState];
        }
    }
    if(self.mouseIsInside) {
        NSColor *backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.5];
        [backgroundColor setFill];

        [path fill];
        
        // Draw Action Image
        NSImage *actionImage = [NSImage imageNamed:NSImageNameActionTemplate];
        NSSize actionSize = NSMakeSize(14.0, 14.0);
        [actionImage setSize:actionSize];

        [actionImage lockFocus];
        [[NSColor whiteColor] set];
        NSRectFillUsingOperation(NSMakeRect(0, 0, actionSize.width, actionSize.height), NSCompositingOperationSourceAtop);

        [actionImage unlockFocus];

        NSPoint actionImageOrigin = NSZeroPoint;
        actionImageOrigin.x = NSMidX(boxRect) - (0.5 * actionSize.width);
        actionImageOrigin.y = NSMidY(boxRect) - (0.5 * actionSize.height);
        [NSGraphicsContext saveGraphicsState];
        [actionImage drawAtPoint:actionImageOrigin fromRect:NSZeroRect operation:NSCompositingOperationSourceAtop fraction:1.0];
                
        [NSGraphicsContext restoreGraphicsState];

    }

    NSColor *strokeColor = [self.enclosingScrollView.documentView gridColor];

    if(self.backgroundStyle == NSBackgroundStyleDark && hasPreviewImage == NO) {
        strokeColor = [NSColor colorWithCalibratedWhite:0.8 alpha:1.0];
    }
    [strokeColor setStroke];
    [path stroke];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
    return self.menu;
}

- (void)mouseDown:(NSEvent *)event {
    [self.menu popUpMenuPositioningItem:nil atLocation:NSZeroPoint inView:self];
}

- (BOOL)objectValueIsValid {
    return (self.objectValue != nil && [self.objectValue isKindOfClass:[NSData class]]);
}

- (NSImage *)imageFromObjectValue {
    if([self objectValueIsValid] == NO) {
        return nil;
    }
    
    return [[NSImage alloc] initWithData:self.objectValue];
}

#pragma mark - Event Handling
- (void)updateTrackingAreas {
    [self removeTrackingArea:self.trackingArea];
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                options: (NSTrackingMouseEnteredAndExited  | NSTrackingActiveInKeyWindow)
                                                  owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
    self.mouseIsInside = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event {
    self.mouseIsInside = NO;
    [self setNeedsDisplay:YES];
}


@end
