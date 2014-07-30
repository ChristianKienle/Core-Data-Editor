#import "NSShadow-CDEAdditions.h"

@implementation NSShadow (CDEAdditions)

#pragma mark Creating Shadows
+ (NSShadow *)cde_embossShadow {
    NSShadow *shadow = [NSShadow new];
   shadow.shadowColor = [[NSColor whiteColor] colorWithAlphaComponent:0.5];
   shadow.shadowOffset = NSMakeSize(0.0f, -1.0f);
   shadow.shadowBlurRadius = 0.0;
   return shadow;
}

@end
