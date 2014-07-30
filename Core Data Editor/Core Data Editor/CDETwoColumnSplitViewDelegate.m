#import "CDETwoColumnSplitViewDelegate.h"

@interface CDETwoColumnSplitViewDelegate () <NSSplitViewDelegate>
@property (nonatomic, weak) NSSplitView *splitView;
@property (nonatomic, weak) IBOutlet NSView *dividerHandleView;

@end

@implementation CDETwoColumnSplitViewDelegate
#pragma mark Sizing Options
- (CGFloat)minWidthOfLeftView {
    return 100.0;
}


- (CGFloat)maxWidthOfLeftView {
    return 350;
}


#pragma mark Properties
- (NSView *)leftView {
    return [self.splitView subviews][0];
}

- (NSView *)centerView {
    return [self.splitView subviews][1];
}

#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)aSplitView canCollapseSubview:(NSView *)subview {
    self.splitView = aSplitView;
    return NO;
    return (subview != self.centerView);
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
    self.splitView = aSplitView;
//    if(dividerIndex == 1) {
//        return NSWidth(self.splitView.bounds) - [self maxWidthOfRightView];;
//    }
    return [self minWidthOfLeftView];
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
    self.splitView = aSplitView;
//    if(dividerIndex == 1) {
//        return proposedMax - [self minWidthOfRightView];
//    }
    if(dividerIndex == 0) {
        return [self maxWidthOfLeftView];
    }
    return proposedMax;
}

- (BOOL)splitView:(NSSplitView *)aSplitView shouldAdjustSizeOfSubview:(NSView *)subview {
    self.splitView = aSplitView;
    return (subview == self.centerView);
}

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
    if(self.dividerHandleView == nil) {
        return NSZeroRect;
    }
    
    return [self.dividerHandleView convertRect:[self.dividerHandleView bounds] toView:splitView];
}


@end
