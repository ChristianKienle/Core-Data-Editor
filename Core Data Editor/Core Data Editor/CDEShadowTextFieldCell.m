#import "CDEShadowTextFieldCell.h"
#import "NSShadow-CDEAdditions.h"

@implementation CDEShadowTextFieldCell

#pragma mark NSCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
   [NSGraphicsContext saveGraphicsState];
   [[NSShadow cde_embossShadow] set];
   [super drawWithFrame:cellFrame inView:controlView];
   [NSGraphicsContext restoreGraphicsState];
}

@end
