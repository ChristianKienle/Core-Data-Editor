#import "CDEDateTableViewCell.h"
#import "CDEAttributeTableViewCell_Subclass.h"

@interface CDEDateTableViewCell () <UIActionSheetDelegate>

@end

@implementation CDEDateTableViewCell

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  [self showDatePicker:self];
  return NO;
}
- (IBAction)showDatePicker:(id)sender {
  NSLog(@"date picker");
  UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Date Picker"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"OK",nil];
  // Add the picker
  UIDatePicker *pickerView = [[UIDatePicker alloc] init];
  pickerView.datePickerMode = UIDatePickerModeTime;
  [menu addSubview:pickerView];
  [menu showInView:self.window.rootViewController.view];
  
  CGRect menuRect = menu.frame;
  CGFloat orgHeight = menuRect.size.height;
  menuRect.origin.y -= 214; //height of picker
  menuRect.size.height = orgHeight+214;
  menu.frame = menuRect;
  
  
  CGRect pickerRect = pickerView.frame;
  pickerRect.origin.y = orgHeight;
  pickerView.frame = pickerRect;


}

@end
