#import <Cocoa/Cocoa.h>

@class CDEPathPickerPopUpButton;

typedef void(^CDEPathPickerPopUpButtonOtherItemSelectedHandler)(CDEPathPickerPopUpButton *sender);

@interface CDEPathPickerPopUpButton : NSPopUpButton

#pragma mark - Properties
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) CDEPathPickerPopUpButtonOtherItemSelectedHandler otherItemSelectedHandler;

@end
