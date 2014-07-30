#import <Cocoa/Cocoa.h>

@class CDEModelChooserItem;

typedef NS_ENUM(NSUInteger, CDEModelChooserSheetControllerResult) {
    CDEModelChooserSheetControllerResultOKButton,
    CDEModelChooserSheetControllerResultCancelButton
};

typedef void (^CDEModelChooserSheetControllerCompletionHandler)(CDEModelChooserSheetControllerResult result, CDEModelChooserItem *item);

@interface CDEModelChooserSheetController : NSWindowController

#pragma mark - Setting the displayed Model Chooser Items
- (void)setDisplayedModelChooserItems:(NSArray *)modelChooserItems;

#pragma mark Running the Model Chooser
- (void)beginSheetModalForWindow:(NSWindow *)parentWindow completionHandler:(CDEModelChooserSheetControllerCompletionHandler)handler;

@end
