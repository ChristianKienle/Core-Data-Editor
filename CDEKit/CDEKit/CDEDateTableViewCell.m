#import "CDEDateTableViewCell.h"
#import "CDEAttributeTableViewCell_Subclass.h"

@interface CDEDateTableViewCell () <UIActionSheetDelegate>

@end

@implementation CDEDateTableViewCell

//- (void)setSelected:(BOOL)selected {
//  [super setSelected:selected];
//  if(selected) {
//    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Date Picker"
//                                                      delegate:self
//                                             cancelButtonTitle:@"Cancel"
//                                        destructiveButtonTitle:nil
//                                             otherButtonTitles:nil];
//    
//    // Add the picker
//    UIDatePicker *pickerView = [[UIDatePicker alloc] init];
//    pickerView.datePickerMode = UIDatePickerModeDate;
//    [menu addSubview:pickerView];
//    [menu showInView:self.window.rootViewController.view];
//    [menu setBounds:CGRectMake(0,0,320, 500)];
//    
//    CGRect pickerRect = pickerView.bounds;
//    pickerRect.origin.y = -100;
//    pickerView.bounds = pickerRect;
//  }
//
//  
//}
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//  [super setSelected:selected animated:animated];
//  if(selected) {
//    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Date Picker"
//                                                      delegate:self
//                                             cancelButtonTitle:@"Cancel"
//                                        destructiveButtonTitle:nil
//                                             otherButtonTitles:nil];
//    
//    // Add the picker
//    UIDatePicker *pickerView = [[UIDatePicker alloc] init];
//    pickerView.datePickerMode = UIDatePickerModeDate;
//    [menu addSubview:pickerView];
//    [menu showInView:self.window.rootViewController.view];
//    [menu setBounds:CGRectMake(0,0,320, 500)];
//    
//    CGRect pickerRect = pickerView.bounds;
//    pickerRect.origin.y = -100;
//    pickerView.bounds = pickerRect;
//  }
//  
//}

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
