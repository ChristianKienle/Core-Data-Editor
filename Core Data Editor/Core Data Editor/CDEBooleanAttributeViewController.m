#import "CDEBooleanAttributeViewController.h"

@interface CDEBooleanAttributeViewController ()

#pragma mark - Properties
@property (nonatomic, weak) IBOutlet NSButton *booleanValueControl;

@end

@implementation CDEBooleanAttributeViewController

#pragma mark CMKViewController
- (NSString *)nibName {
    return @"CDEBooleanAttributeView";
}

#pragma mark - UI
- (void)updateAttributeNameUI {
    self.booleanValueControl.title = self.attributeDescription.nameForDisplay_cde;
}

@end
