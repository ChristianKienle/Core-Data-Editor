//
//  CDEUUIDAttributeViewController.m
//  Core Data Editor
//
//  Created by Steve Madsen on 8/15/19.
//  Copyright © 2019 Christian Kienle. All rights reserved.
//

#import "CDEUUIDAttributeViewController.h"

@implementation CDEUUIDAttributeViewController

#pragma mark CMKViewController
- (NSString *)nibName {
    return @"CDEUUIDAttributeView";
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    if ([[NSUUID alloc] initWithUUIDString:[fieldEditor string]] != nil) {
        return YES;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.informativeText = [NSString stringWithFormat:@"Input '%@' is not a UUID", [fieldEditor string]];
    alert.messageText = @"Validation Error";
    [alert runModal];

    return NO;
}

- (void) setResultingValue:(id)newValue {
    [super setResultingValue:[[NSUUID alloc] initWithUUIDString:newValue]];
}

@end
