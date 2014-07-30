#import <Cocoa/Cocoa.h>

@protocol CDEDatePickerViewControllerDelegate;
@interface CDEDatePickerViewController : NSViewController

#pragma mark Properties
@property (nonatomic, weak) IBOutlet NSDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet NSDatePicker *dateTimePicker;
@property (nonatomic, assign) id<CDEDatePickerViewControllerDelegate> delegate;

#pragma mark Actions
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;

@end
