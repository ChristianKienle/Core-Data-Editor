#import "CDEFloatingPointNumberTableViewCell.h"
#import "CDEAttributeTableViewCell_Subclass.h"

@implementation CDEFloatingPointNumberTableViewCell


#pragma mark - UI
- (void)updateUI {
  [super updateUI];
  id value = [self.managedObject valueForKey:self.propertyDescription.name];
  NSNumberFormatter *formatter = [self numberFormatter];
  NSString *string = [formatter stringFromNumber:value];
  [self valueTextField].text = string;
}

#pragma mark - Helper
- (UITextField *)valueTextField {
  return (UITextField *)self.attributeValueView;
}

#pragma mark - Value View
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if([self valueTextField].inputAccessoryView == nil) {
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlack;
    numberToolbar.translucent = YES;
    numberToolbar.items = [NSArray arrayWithObjects:
                           //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(useCurrentValueTextFieldContents:)],
                           nil];
    [numberToolbar sizeToFit];
    [self valueTextField].inputAccessoryView = numberToolbar;
  }
  return YES;
}

- (void)useCurrentValueTextFieldContents:(id)sender {
  [[self valueTextField] resignFirstResponder];
}

- (NSNumberFormatter *)numberFormatter {
  NSInteger decimalCount = 3;
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setMinimumFractionDigits:0];
  [formatter setMaximumFractionDigits:(NSUInteger)decimalCount];
  [formatter setMinimumIntegerDigits:0];
  [formatter setMaximumIntegerDigits:42];

  return formatter;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  NSNumber *number = [[self numberFormatter] numberFromString:[self valueTextField].text];
  [self.managedObject setValue:number forKey:self.propertyDescription.name];
  [self valueTextField].inputAccessoryView = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}
@end
