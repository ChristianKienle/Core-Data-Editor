#import <Cocoa/Cocoa.h>
#import "CDEAttributeViewController.h"

#import "CDEDatePickerWindowDelegate.h"

@class CDEDatePickerWindow;
@interface CDEDateAttributeViewController : CDEAttributeViewController <CDEDatePickerWindowDelegate>

#pragma mark Actions
- (IBAction)showDatePicker:(id)sender;

@end
