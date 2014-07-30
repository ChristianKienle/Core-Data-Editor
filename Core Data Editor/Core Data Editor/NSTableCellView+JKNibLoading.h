//
//  NSTableCellView+JKNibLoading.h
//  Core Data Editor
//
//  Created by cmk on 6/22/13.
//  Copyright (c) 2013 Christian Kienle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTableCellView (JKNibLoading)
+ (instancetype)newTableCellViewWithNibNamed:(NSString *)nibName owner:(id)owner;
@end
