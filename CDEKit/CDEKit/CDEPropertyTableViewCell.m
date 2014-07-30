#import "CDEPropertyTableViewCell.h"
#import "CDEAttributeTableViewCell.h"

@implementation CDEPropertyTableViewCell

#pragma mark - Manual loading
+ (void)initialize {
  if(self == [CDEPropertyTableViewCell class]) {
    [CDEAttributeTableViewCell class]; // load
  }
}

#pragma mark - UI
- (void)updateUI {
  // Implemented by subclasses
}

@end
