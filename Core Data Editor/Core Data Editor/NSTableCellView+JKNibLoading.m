//
//  NSTableCellView+JKNibLoading.m
//  Core Data Editor
//
//  Created by cmk on 6/22/13.
//  Copyright (c) 2013 Christian Kienle. All rights reserved.
//

#import "NSTableCellView+JKNibLoading.h"

@implementation NSTableCellView (JKNibLoading)

+ (instancetype)newTableCellViewWithNibNamed:(NSString *)nibName owner:(id)owner
{
    NSTableCellView *view = nil;
    NSArray * topLevelObjects = nil;
    
    NSNib * nib = [[NSNib alloc] initWithNibNamed:nibName bundle:nil];
    if (!nib || ![nib instantiateWithOwner:owner topLevelObjects:&topLevelObjects]) {
        return nil;
    }
    
    for (id obj in topLevelObjects) {
        if ([obj isKindOfClass:[self class]]) {
            view = obj;
            break;
        }
    }
	
    return view;
}

@end