#import <Cocoa/Cocoa.h>

@class CDEDropZoneView;

@protocol CDEDropZoneViewDelegate <NSObject>

@required
#pragma mark Properties
- (NSString *)titleForDropZoneView:(CDEDropZoneView *)view;

#pragma mark Drag and Drop
- (NSDragOperation)dropZoneView:(CDEDropZoneView *)view validateDrop:(id<NSDraggingInfo>)info;
- (BOOL)dropZoneView:(CDEDropZoneView *)view acceptDrop:(id<NSDraggingInfo>)info;

#pragma mark Reacting to Drops
- (void)dropZoneView:(CDEDropZoneView *)view didChangeURL:(NSURL *)newURL;

@end
