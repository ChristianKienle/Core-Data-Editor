#import "CDETextEditorController.h"
#import "CDETextEditorViewController.h"

@interface CDETextEditorController () <NSPopoverDelegate>

#pragma mark - Properties
@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, copy) CDETextEditorControllerCompletionHandler completionHandler;

@end

@implementation CDETextEditorController
#pragma mark - Creating
- (instancetype)init {
    self = [super init];
    if(self) {
        CDETextEditorViewController *viewController = [CDETextEditorViewController new];
        self.popover = [NSPopover new];
        [self.popover setContentViewController:viewController];
        [self.popover setBehavior:NSPopoverBehaviorSemitransient];
        [self.popover setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
        self.popover.delegate = self;
    }
    return self;
}

#pragma mark - Showing the Editor
- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge stringValue:(NSString *)stringValue completionHandler:(CDETextEditorControllerCompletionHandler)completionHandler {
    self.completionHandler = completionHandler;
    self.popover.contentViewController.representedObject = stringValue;
    [self.popover showRelativeToRect:positioningRect ofView:positioningView preferredEdge:preferredEdge];
}

#pragma mark - NSPopoverDelegate
- (void)popoverDidClose:(NSNotification *)notification {
    self.completionHandler ? self.completionHandler(self.popover.contentViewController.representedObject) : nil;
    self.popover.contentViewController.representedObject = nil;
}

@end
