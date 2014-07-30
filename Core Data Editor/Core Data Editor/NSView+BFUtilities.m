//
//  NSView+BFUtilities.m
//
//  Created by Heiko Dreyer on 27.04.12.
//  Copyright (c) 2012 boxedfolder.com. All rights reserved.
//

#import "NSView+BFUtilities.h"

@implementation NSView (BFUtilities)

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

-(NSImage *)flattenWithSubviews
{
    NSRect bounds = self.bounds;
    NSSize size = bounds.size;
    NSRect fBounds = bounds;
    NSPoint offset = NSZeroPoint;
    
    // Don't draw anything if zero size
    if(NSEqualSizes(NSZeroSize, size))
        return nil;
    
    NSScrollView *hScrollView = self.enclosingScrollView;
     
    // Check if there is an enclosing scrollview
    if(hScrollView) 
    {
        NSPoint botLeft;
        botLeft.x = NSMinX(hScrollView.bounds);
        botLeft.y = hScrollView.isFlipped ? NSMaxY(hScrollView.bounds) : NSMinY(hScrollView.bounds);
        offset = [hScrollView convertPoint: botLeft toView: hScrollView.window.contentView];
    }
    
    fBounds.origin.x -= offset.x;
    fBounds.origin.y -= offset.y;
    fBounds.size.width += offset.x;
    fBounds.size.height += offset.x;
    
    NSSize fSize = fBounds.size;
    NSBitmapImageRep *bitmapRep = [self bitmapImageRepForCachingDisplayInRect: fBounds];
    [bitmapRep setSize: fSize];
    [self cacheDisplayInRect: fBounds toBitmapImageRep: bitmapRep];
    
    NSImage *image = [[NSImage alloc] initWithSize: size];
    [image lockFocus];
    [bitmapRep drawAtPoint: fBounds.origin];
    [image unlockFocus];
    bitmapRep = nil;
    return image;
}

@end
