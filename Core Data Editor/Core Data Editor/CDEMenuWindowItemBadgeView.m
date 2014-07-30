#import "CDEMenuWindowItemBadgeView.h"

static CGFloat const kcdeBadgeMargin = 3;
static CGFloat const kcdeBadgePadding = 5;
static CGFloat const kcdeBadgeWidthMin = 10;

@interface CDEMenuWindowItemBadgeView ()

@end

@implementation CDEMenuWindowItemBadgeView

#pragma mark Creating
- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if(self) {
    self.selected = NO;
    self.showsBadge = NO;
    self.badgeValue = [NSString string];
  }
  return self;
}

#pragma mark Properties
- (void)setSelected:(BOOL)newSelectedValue {
  _selected = newSelectedValue;
  [self setNeedsDisplay:YES];
}

- (void)setBadgeValue:(NSString *)newBadgeValue {
  if(newBadgeValue != _badgeValue) {
    _badgeValue = [newBadgeValue copy];
    [self setNeedsDisplay:YES];
  }
}

- (void)setShowsBadge:(BOOL)newShowsBadgeFlag {
  _showsBadge = newShowsBadgeFlag;
  [self setNeedsDisplay:YES];
}


#pragma mark NSView
- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  //[[self backgroundColor] set];
  //[NSBezierPath fillRect:self.bounds];
  
  NSRect badgeBackgroundFrame = NSZeroRect;
	// Badge anzeigen?
	if(self.showsBadge)
	{
		
		// Fenster + Fokus
		
		// Badge-Farben setzen
		NSColor *badgeTextColor = [self textColor];
    
		
		
		NSDictionary *badgeTextAttributes = [NSMutableDictionary dictionary];
		[badgeTextAttributes setValue:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] forKey:NSFontAttributeName];
		[badgeTextAttributes setValue:badgeTextColor forKey:NSForegroundColorAttributeName];
		
		NSAttributedString *badgeAttributedText = [[NSAttributedString alloc] initWithString:self.badgeValue attributes:badgeTextAttributes];
		
		
		// Badge-Text
		NSSize badgeTextSize = [badgeAttributedText size];
		CGFloat badgeTextHeight = badgeTextSize.height;
		CGFloat badgeTextWidth = badgeTextSize.width;
		CGFloat badgeTextMiddleY = ((NSHeight(self.bounds) / 2) - (badgeTextHeight / 2));
		NSRect textFrame = self.bounds;
		NSRect badgeTextFrame = textFrame;
		badgeTextFrame.origin.x += textFrame.size.width - badgeTextWidth - kcdeBadgePadding - kcdeBadgeMargin;
		badgeTextFrame.origin.y += badgeTextMiddleY;
		badgeTextFrame.size.width = badgeTextWidth ;
		badgeTextFrame.size.height = badgeTextHeight;
		
		// Badge-Hintergrund
		badgeBackgroundFrame = badgeTextFrame;
		badgeBackgroundFrame.size.width += (2 * kcdeBadgePadding);
		badgeBackgroundFrame.origin.x -= kcdeBadgePadding;
		
		// Badge hat Mindestgröße=
		if(badgeTextWidth < kcdeBadgeWidthMin) {
			
			badgeTextFrame.origin.x -= (kcdeBadgeWidthMin / 4) - 1;
			badgeBackgroundFrame.origin.x -= (kcdeBadgeWidthMin / 2);
			badgeBackgroundFrame.size.width += (kcdeBadgeWidthMin / 2);
		}
		
		// Bagge Position prüfen
		if (badgeBackgroundFrame.origin.x <= textFrame.origin.x)
		{
			//return;
		}
		
		// Badge-Hintergrund zeichnen
		NSBezierPath *badgeBackgroundPath = [NSBezierPath bezierPathWithRoundedRect:badgeBackgroundFrame xRadius:7 yRadius:8];
    [[self backgroundColor] set];
		[badgeBackgroundPath fill];
		
		// Badge-Text zeichnen
    [[self textColor] set];
		[badgeAttributedText drawInRect:badgeTextFrame];
  }
}

#pragma mark Helper
- (NSColor *)backgroundColor {
  if(self.isSelected) {
    return [NSColor whiteColor];
  }
  return [NSColor grayColor];
}

- (NSColor *)textColor {
  if(self.isSelected) {
    return [NSColor colorWithCalibratedRed:0.283 green:0.403 blue:0.920 alpha:1.000];
  }
  return [NSColor whiteColor];
}
@end
