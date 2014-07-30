#import <Cocoa/Cocoa.h>
#import "CDEAttributeViewController.h"

@interface CDEBinaryAttributeViewController : CDEAttributeViewController

#pragma mark Properties
@property (nonatomic, assign) IBOutlet NSImageView *previewImageView;

#pragma mark Actions
- (IBAction)saveResultingValueAs:(id)sender;
- (IBAction)setResultingValueFromFile:(id)sender;
- (IBAction)setResultingValueToNil:(id)sender;
- (IBAction)openInPreview:(id)sender;
- (IBAction)openWithQuickLook:(id)sender;
- (IBAction)generateThumbnail:(id)sender;

@end
