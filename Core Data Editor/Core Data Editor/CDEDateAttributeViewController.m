#import "CDEDateAttributeViewController.h"
#import "CDEDatePickerWindow.h"

@interface CDEDateAttributeViewController ()

#pragma mark Properties
@property (strong) CDEDatePickerWindow *datePickerWindow;

@end

@implementation CDEDateAttributeViewController

#pragma mark CMKViewController
- (NSString *)nibName {
    return @"CDEDateAttributeView";
}

#pragma mark Creating
- (id)initWithManagedObject:(NSManagedObject *)initManagedObject attributeDescription:(NSAttributeDescription *)initAttributeDescription delegate:(id<CDEAttributeViewControllerDelegate>)initDelegate {
   self = [super initWithManagedObject:initManagedObject attributeDescription:initAttributeDescription delegate:initDelegate];
   if(self) {
       self.datePickerWindow = [CDEDatePickerWindow new];
   }
   return self;
}

#pragma mark Actions
- (IBAction)showDatePicker:(id)sender {
   NSButton *showDatePickerButton = (NSButton *)sender;
   NSDate *dateToShow = [NSDate date];
   if([self resultingValue] != nil) {
      dateToShow = [self resultingValue];
   }
   self.datePickerWindow.delegate = self;
   [self.datePickerWindow showRelativeToRect:showDatePickerButton.bounds ofView:showDatePickerButton preferredEdge:NSMinYEdge andDisplayDate:dateToShow];
}

#pragma mark CDEDatePickerWindowDelegate
- (void)datePickerWindow:(CDEDatePickerWindow *)datePickerWindow didConfirmDate:(NSDate *)confirmedDate {
   [self setResultingValue:confirmedDate];
}

- (void)datePickerWindowDidCancel:(CDEDatePickerWindow *)datePickerWindow {
   // Do nothing
}

@end
