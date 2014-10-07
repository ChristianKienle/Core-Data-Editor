#import "CDEEntityTableCellView.h"

@interface CDEEntityTableCellView ()

@end

@implementation CDEEntityTableCellView


#pragma mark - Properties
- (void)setBadgeValue:(NSInteger)badgeValue {
  _badgeValue = badgeValue;
  [self.badgeButton setTitle:[NSString stringWithFormat:@"%li", self.badgeValue]];
  [self performCustomLayout];
}

#pragma mark - NSView

- (void)awakeFromNib {
  // We want it to appear "inline"
  [[self.badgeButton cell] setBezelStyle:NSInlineBezelStyle];
}

- (void)setObjectValue:(id)objectValue {
  [super setObjectValue:objectValue];
}

- (void)viewWillDraw {
  [super viewWillDraw];
  [self.badgeButton setTitle:[NSString stringWithFormat:@"%li", self.badgeValue]];
  
  [self.badgeButton sizeToFit];
  
  NSRect textFrame = self.textField.frame;
  NSRect buttonFrame = self.badgeButton.frame;
  buttonFrame.origin.x = NSWidth(self.frame) - NSWidth(buttonFrame);
  self.badgeButton.frame = buttonFrame;
  textFrame.size.width = NSMinX(buttonFrame) - NSMinX(textFrame);
  self.textField.frame = textFrame;
}

- (void)performCustomLayout {
  [self.badgeButton sizeToFit];
  
  NSRect textFrame = self.textField.frame;
  NSRect buttonFrame = self.badgeButton.frame;
  buttonFrame.origin.x = NSWidth(self.frame) - NSWidth(buttonFrame);
  self.badgeButton.frame = buttonFrame;
  textFrame.size.width = NSMinX(buttonFrame) - NSMinX(textFrame);
  self.textField.frame = textFrame;
}

@end
