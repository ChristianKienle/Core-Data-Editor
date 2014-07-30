#import "CDEBoolTableViewCell.h"
#import "CDEAttributeTableViewCell_Subclass.h"

@implementation CDEBoolTableViewCell

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
  UISwitch *valueSwitch = (UISwitch *)self.attributeValueView;
  valueSwitch.on = value == nil ? NO : [value boolValue];
}

#pragma mark - Value View
- (IBAction)takeBoolValueFromSender:(id)sender {
  [self.managedObject setValue:@([sender isOn]) forKey:self.propertyDescription.name];

}

@end
