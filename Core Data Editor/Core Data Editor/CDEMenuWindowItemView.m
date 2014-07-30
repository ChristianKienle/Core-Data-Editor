#import "CDEMenuWindowItemView.h"
#import "CDEMenuWindowItemBadgeView.h"
#import "CDEMenuItem.h"

@interface CDEMenuWindowItemView ()

#pragma mark Properties
@property (nonatomic, retain) NSTrackingArea *hoverTrackingArea;
@property (nonatomic, getter = isSelected) BOOL selected;

#pragma mark Drawing
- (void)drawBackground;
- (void)drawSelectionBackground;

@end

@implementation CDEMenuWindowItemView

- (id)initWithFrame:(NSRect)frame {
   self = [super initWithFrame:frame];
   if(self) {
      self.target = nil;
      self.action = nil;
      self.selected = NO;
      self.hoverTrackingArea = nil;
      self.item = nil;
   }
   return self;
}

#pragma mark Properties
- (void)setSelected:(BOOL)newSelectedValue {
   _selected = newSelectedValue;
   self.badgeView.selected = self.selected;
   [self setNeedsDisplay:YES];
}

- (void)setItem:(CDEMenuItem *)newItem {
   _item = newItem;
   self.badgeView.badgeValue = self.item.badgeValue;
   self.badgeView.showsBadge = self.item.showsBadge;
}

@synthesize badgeView;

#pragma mark Drawing
- (void)drawBackground {
   if(self.isSelected) {
      [self drawSelectionBackground];
   }
}

- (void)drawSelectionBackground {
   NSColor *topGradientColor = [NSColor colorWithCalibratedRed:0.054 green:0.215 blue:0.906 alpha:1.000];
   NSColor *bottomGradientColor = [NSColor colorWithCalibratedRed:0.283 green:0.403 blue:0.920 alpha:1.000];
   NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:topGradientColor endingColor:bottomGradientColor];
   NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:5.0 yRadius:5.0];
   [backgroundGradient drawInBezierPath:path angle:90.0];
}

#pragma mark NSView
- (void)drawRect:(NSRect)dirtyRect {
   [super drawRect:dirtyRect];
   [self drawBackground];
}

- (void)updateTrackingAreas {
   [super updateTrackingAreas];
   
   if(self.hoverTrackingArea != nil) {
      [self removeTrackingArea:self.hoverTrackingArea];
   }
   
   self.hoverTrackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:[NSDictionary dictionary]];
   [self addTrackingArea:self.hoverTrackingArea];
}

#pragma mark NSResponder
- (void)mouseEntered:(NSEvent *)event {
   [super mouseEntered:event];
   self.selected = YES;
}

- (void)mouseExited:(NSEvent *)event {
   [super mouseExited:event];
   self.selected = NO;
}

- (void)mouseUp:(NSEvent *)event {
   [super mouseUp:event];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
   [self.target performSelector:self.action withObject:self.item];
#pragma clang diagnostic pop
}

@end
