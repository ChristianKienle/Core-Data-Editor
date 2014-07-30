#import <Foundation/Foundation.h>

#import "CDEDatePickerViewControllerDelegate.h"

@protocol CDEDatePickerWindowDelegate;

@class CDEDatePickerViewController;
@interface CDEDatePickerWindow : NSObject <CDEDatePickerViewControllerDelegate>

#pragma mark Properties
@property (nonatomic, assign) IBOutlet id<CDEDatePickerWindowDelegate> delegate;
@property (nonatomic, strong) id representedObject; // can be anything but in general it is a NSManagedObject

#pragma mark Actions
- (IBAction)confirmCurrentDate:(id)sender;
- (IBAction)cancel:(id)sender;

#pragma mark Showing the Window
- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge andDisplayDate:(NSDate *)date;

@end
