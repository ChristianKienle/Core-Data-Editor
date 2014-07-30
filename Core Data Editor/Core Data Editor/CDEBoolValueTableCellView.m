//
//  CDEBoolValueTableCellView.m
//  Core Data Editor
//
//  Created by cmk on 6/22/13.
//  Copyright (c) 2013 Christian Kienle. All rights reserved.
//

#import "CDEBoolValueTableCellView.h"

@implementation CDEBoolValueTableCellView

- (id)initWithCoder:(NSCoder *)decoder {
    //NSLog(@"CDEBoolValueTableCellView");
    return [super initWithCoder:decoder];
}
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"Frame");
    }
    
    return self;
}



@end
