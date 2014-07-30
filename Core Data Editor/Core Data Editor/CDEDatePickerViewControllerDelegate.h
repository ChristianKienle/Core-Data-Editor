#import <Foundation/Foundation.h>

@class CDEDatePickerViewController;
@protocol CDEDatePickerViewControllerDelegate <NSObject>

@required
- (void)datePickerViewControllerDidCancel:(CDEDatePickerViewController *)controller;
- (void)datePickerViewControllerDidConfirmDate:(CDEDatePickerViewController *)controller;

@end
