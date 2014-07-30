#import <Foundation/Foundation.h>

@class CDEDatePickerWindow;
@protocol CDEDatePickerWindowDelegate <NSObject>

@required
- (void)datePickerWindow:(CDEDatePickerWindow *)datePickerWindow didConfirmDate:(NSDate *)confirmedDate;
- (void)datePickerWindowDidCancel:(CDEDatePickerWindow *)datePickerWindow;

@end
