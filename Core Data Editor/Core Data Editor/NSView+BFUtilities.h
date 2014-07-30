//
//  NSView+BFUtilities.h
//
//  Created by Heiko Dreyer on 27.04.12.
//  Copyright (c) 2012 boxedfolder.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (BFUtilities)

///---------------------------------------------------------------------------------------
/// @name Flattening View Hierarchy
///---------------------------------------------------------------------------------------

/**
 *  Flatten self + subviews, return proper NSImage.
 */
-(NSImage *)flattenWithSubviews;

@end
