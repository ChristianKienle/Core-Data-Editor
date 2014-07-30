#import <Cocoa/Cocoa.h>

@protocol CDEDropZoneViewDelegate;

@interface CDEDropZoneView : NSView <NSAnimationDelegate>

#pragma mark Properties
@property (nonatomic, readwrite, copy) NSURL *URL;
@property (nonatomic, assign) IBOutlet id<CDEDropZoneViewDelegate> delegate;
@property (nonatomic, readwrite, copy) NSError *displayedError;

@end
