#import "CDEAttributeTableViewCell.h"
#import "CDEAttributeTableViewCell_Subclass.h"
#import "CDEStringTableViewCell.h"
#import "CDEBoolTableViewCell.h"
#import "CDEIntegerTableViewCell.h"
#import "CDEFloatingPointNumberTableViewCell.h"
#import "CDEDateTableViewCell.h"

@implementation CDEAttributeTableViewCell

#pragma mark - Manual loading
+ (void)initialize {
  if(self == [CDEAttributeTableViewCell class]) {
    [CDEStringTableViewCell class]; // load
    [CDEBoolTableViewCell class]; // load
    [CDEIntegerTableViewCell class]; // load
    [CDEFloatingPointNumberTableViewCell class]; // load
    [CDEDateTableViewCell class]; // load
  }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UI
- (void)updateUI {
  [super updateUI];
  self.attributeNameLabel.text = self.propertyDescription.name;
}

@end
