#import "CDEBadgeView.h"
//static CGFloat const kIconMargin = 4;
static CGFloat const kBadgeMargin = 3;
static CGFloat const kBadgePadding = 5;
static CGFloat const kBadgeWidthMin = 10;

@interface CDEBadgeView ()

#pragma mark - Properties
@property (nonatomic, assign) NSBackgroundStyle backgroundStyle;

@end

@implementation CDEBadgeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.badgeValue = 0;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor redColor] setFill];
    NSRectFill(self.bounds);
    NSColor *badgeTextColor = [NSColor whiteColor];
    if([self backgroundStyle] == NSBackgroundStyleLight) {
        // normal
        [[NSColor colorWithCalibratedRed:0.53 green:0.60 blue:0.74 alpha:1.0] set];
        
//        if(self.highlightBadge) {
//            [[NSColor colorWithCalibratedRed:0.552 green:0.026 blue:0.000 alpha:1.000] set];
//        }
        
    }
    else {
        // selected
        [[NSColor whiteColor] set];
        badgeTextColor = [NSColor colorWithCalibratedRed:0.51 green:0.58 blue:0.72 alpha:1.0];
    }
    
    
    NSDictionary *badgeTextAttributes = [NSMutableDictionary dictionary];
    [badgeTextAttributes setValue:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] forKey:NSFontAttributeName];
    [badgeTextAttributes setValue:badgeTextColor forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *badgeAttributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)self.badgeValue]
                                                                               attributes:badgeTextAttributes
                                                ];
    
    
    // Badge-Text
    NSSize badgeTextSize = [badgeAttributedText size];
    CGFloat badgeTextHeight = badgeTextSize.height;
    CGFloat badgeTextWidth = badgeTextSize.width;
    CGFloat badgeTextMiddleY = ((NSHeight(self.bounds) / 2) - (badgeTextHeight / 2));
    
    NSRect badgeTextFrame = NSZeroRect;
    badgeTextFrame.origin.x += badgeTextWidth - kBadgePadding - kBadgeMargin;
    badgeTextFrame.origin.y += badgeTextMiddleY;
    badgeTextFrame.size.width = badgeTextWidth ;
    badgeTextFrame.size.height = badgeTextHeight;
    
    // Badge-Hintergrund
    NSRect badgeBackgroundFrame = NSZeroRect;
    badgeBackgroundFrame = badgeTextFrame;
    badgeBackgroundFrame.size.width += (2 * kBadgePadding);
    badgeBackgroundFrame.origin.x -= kBadgePadding;
    
    // Badge hat Mindestgröße=
    if(badgeTextWidth < kBadgeWidthMin) {
        
        badgeTextFrame.origin.x -= (kBadgeWidthMin / 4) - 1;
        badgeBackgroundFrame.origin.x -= (kBadgeWidthMin / 2);
        badgeBackgroundFrame.size.width += (kBadgeWidthMin / 2);
    }
    
    
    // Badge-Hintergrund zeichnen
    NSBezierPath *badgeBackgroundPath = [NSBezierPath bezierPathWithRoundedRect:badgeBackgroundFrame xRadius:7 yRadius:8];
    [badgeBackgroundPath fill];
    
    // Badge-Text zeichnen
    [badgeAttributedText drawInRect:badgeTextFrame];
    
    // Text-Frame korrigieren
//    textFrame.size.width -= badgeTextWidth + (2 * kBadgePadding) + (2 * kBadgeMargin);
}

#pragma mark - Properties
- (void)setBadgeValue:(NSInteger)badgeValue {
    _badgeValue = badgeValue;
    [self setNeedsDisplay:YES];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    _backgroundStyle = backgroundStyle;
    [self setNeedsDisplay:YES];
}

@end
