#import "CDEDatePickerWindow.h"
#import "CDEDatePickerViewController.h"
#import "CDEDatePickerWindowDelegate.h"

@interface CDEDatePickerWindow ()

#pragma mark Properties
@property (nonatomic, retain) NSPopover *popover;
@property (nonatomic, retain) CDEDatePickerViewController *datePickerViewController;

#pragma mark Helper
- (void)detachFromParentWindowIfNeededAndOrderOut;

@end

@implementation CDEDatePickerWindow

#pragma mark Creating
- (id)init {
   self = [super init];
   if(self) {      
      self.datePickerViewController = [CDEDatePickerViewController new];
      [self.datePickerViewController view];
      self.datePickerViewController.delegate = self;
      self.popover = [NSPopover new];
      [self.popover setContentViewController:self.datePickerViewController];
      [self.popover setBehavior:NSPopoverBehaviorSemitransient];
      [self.popover setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
   }
   
	return self;
}

#pragma mark NSWindow
- (BOOL)canBecomeKeyWindow {
   return YES;
}

#pragma mark Dealloc
- (void)dealloc {
   self.popover = nil;
   self.delegate = nil;
   self.datePickerViewController = nil;
}

#pragma mark Actions
- (IBAction)confirmCurrentDate:(id)sender {
   [self.delegate datePickerWindow:self didConfirmDate:self.datePickerViewController.datePicker.dateValue];
   [self detachFromParentWindowIfNeededAndOrderOut];
}

- (IBAction)cancel:(id)sender {
   [self.delegate datePickerWindowDidCancel:self];
   [self detachFromParentWindowIfNeededAndOrderOut];
}

#pragma mark Showing the Window
- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge andDisplayDate:(NSDate *)date {
    self.datePickerViewController.datePicker.dateValue = (date != nil ? date : [NSDate new]);
    self.datePickerViewController.dateTimePicker.dateValue = (date != nil ? date : [NSDate new]);
    if(date == nil) {
        self.datePickerViewController.dateTimePicker.textColor = [NSColor lightGrayColor];
    }
    [self.popover showRelativeToRect:positioningRect ofView:positioningView preferredEdge:preferredEdge];
}

#pragma mark Helper
- (void)detachFromParentWindowIfNeededAndOrderOut {
   [self.popover performClose:self];
}

#pragma mark DatePickerViewControllerDelegate
- (void)datePickerViewControllerDidCancel:(CDEDatePickerViewController *)controller {
   [self cancel:self];
}
- (void)datePickerViewControllerDidConfirmDate:(CDEDatePickerViewController *)controller {
   [self confirmCurrentDate:self];
}

@end
