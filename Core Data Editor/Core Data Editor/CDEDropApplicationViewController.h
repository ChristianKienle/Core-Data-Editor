#import <Cocoa/Cocoa.h>

@protocol CDEDropModelViewControllerDelegate;

@interface CDEDropApplicationViewController : NSViewController

#pragma mark Properties
@property (nonatomic, weak) id<CDEDropModelViewControllerDelegate> delegate;
@property (nonatomic, readonly, copy) NSURL *modelURL;
@property (nonatomic, readonly, copy) NSURL *bundleURL;
@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, getter=isEditing) BOOL editing;

#pragma mark Configuring Model and Bundle Information
- (void)setModelURL:(NSURL *)newModelURL bundleURL:(NSURL *)newBundleURL;

@end
