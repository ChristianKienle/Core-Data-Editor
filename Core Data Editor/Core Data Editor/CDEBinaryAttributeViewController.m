#import "CDEBinaryAttributeViewController.h"
#import "CDEAttributeViewControllerDelegate.h"
#import "CDEGenerateThumbnailOperation.h"

@implementation CDEBinaryAttributeViewController

#pragma mark CMKViewController
- (NSString *)nibName {
    return @"CDEBinaryAttributeView";
}

- (void)loadView {
   [super loadView];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGenerateThumbnailOperationDidGenerateThumbnailNotification:) name:CDEGenerateThumbnailOperationDidGenerateThumbnailNotification object:nil];
}

- (void)handleGenerateThumbnailOperationDidGenerateThumbnailNotification:(NSNotification *)notification {
   NSData *inputData = (notification.userInfo)[CDEGenerateThumbnailOperationDidGenerateThumbnailNotificationInputData];
   if(inputData == nil) {
      return;
   }
   
   if([[self resultingValue] isEqualToData:inputData] == NO) {
      return;
   }
   
   NSImage *thumbnail = (notification.userInfo)[CDEGenerateThumbnailOperationDidGenerateThumbnailNotificationGeneratedThumbnail];
   self.previewImageView.image = thumbnail;
}

#pragma mark Properties
- (void)setDelegate:(id<CDEAttributeViewControllerDelegate>)newDelegate {
   [super setDelegate:newDelegate];
}

#pragma mark Dealloc
- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self name:CDEGenerateThumbnailOperationDidGenerateThumbnailNotification object:nil];

   self.previewImageView = nil;
}

#pragma mark CDEAttributeViewController
- (void)didChangeResultingValue {
   [super didChangeResultingValue];
   self.previewImageView.image = nil;
   if([self resultingValue] == nil) {
      return;
   }
   [self generateThumbnail:self];
}

#pragma mark Actions
- (IBAction)saveResultingValueAs:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.canCreateDirectories = YES;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if(result != NSFileHandlingPanelOKButton) {
            return;
        }
        if([[self resultingValue] isKindOfClass:[NSData class]] == NO) {
            return;
        }
        NSURL *URL = panel.URL;
        [(NSData *)[self resultingValue] writeToURL:URL atomically:YES];
    }];
//    NSSavePanel *savePanel = [NSSavePanel savePanel];
//    if([savePanel runModal] != NSFileHandlingPanelOKButton) {
//        return;
//    }
//    [[self resultingValue] writeToFile:[[savePanel URL] path] atomically:YES];
}

- (IBAction)setResultingValueFromFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canCreateDirectories = YES;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if(result != NSFileHandlingPanelOKButton) {
            return;
        }
//        if([[self resultingValue] isKindOfClass:[NSData class]] == NO) {
//            return;
//        }
        NSURL *URL = panel.URL;
        [self setResultingValue:[NSData dataWithContentsOfFile:[URL path]]];
    }];

//    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
//    [openPanel setCanChooseDirectories:NO];
//    if([openPanel runModal] != NSOKButton) {
//        return;
//    }
//    [self setResultingValue:[NSData dataWithContentsOfFile:[[openPanel URL] path]]];
}

- (IBAction)setResultingValueToNil:(id)sender {
    [self setResultingValue:nil];
}

- (IBAction)openInPreview:(id)sender {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    [[self resultingValue] writeToFile:path atomically:YES];
    [[NSWorkspace sharedWorkspace] openFile:path withApplication:@"Preview"];
}

- (IBAction)openWithQuickLook:(id)sender {
   NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
   
   [[self resultingValue] writeToFile:path atomically:YES];

//   CDEQuickLookPreviewItem *item = [[[CDEQuickLookPreviewItem alloc] initWithPreviewItemURL:[NSURL fileURLWithPath:path]] autorelease];
//   NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//   [userInfo setObject:item forKey:CDEQuickLookPreviewItemShowInPreviewPanelNotificationPreviewItem];
   
//   [[NSNotificationCenter defaultCenter] postNotificationName:CDEQuickLookPreviewItemShowInPreviewPanelNotification object:self userInfo:userInfo];
}

- (IBAction)generateThumbnail:(id)sender {
   [self.delegate attributeViewController:self didRequestGenerationOfThumbnailForData:[self resultingValue]];
}

@end
