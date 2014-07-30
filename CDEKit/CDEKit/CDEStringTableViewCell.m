#import "CDEStringTableViewCell.h"
#import "CDEAttributeTableViewCell_Subclass.h"

@implementation CDEStringTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - UI
- (void)updateUI {
  [super updateUI];
  id value = [self.managedObject valueForKey:self.propertyDescription.name];
  UITextField *valueTextField = (UITextField *)self.attributeValueView;
  valueTextField.text = value;
}

#pragma mark - Value View
- (void)textFieldDidEndEditing:(UITextField *)textField {
  [self.managedObject setValue:textField.text forKey:self.propertyDescription.name];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder]; //enable your buttons after this
  return 1;
}

@end
