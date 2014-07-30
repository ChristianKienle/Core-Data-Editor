#import "CDEThreeColumnSplitViewDelegate.h"

@interface CDEThreeColumnSplitViewDelegate ()

#pragma mark Sizing Options
- (CGFloat)minWidthOfLeftView;
- (CGFloat)minWidthOfRightView;
- (CGFloat)maxWidthOfLeftView;
- (CGFloat)maxWidthOfRightView;

#pragma mark Properties
@property (nonatomic, readonly) NSView *leftView;
@property (nonatomic, readonly) NSView *centerView;
@property (nonatomic, readonly) NSView *rightView;
@property (nonatomic, retain) NSSplitView *splitView;

@end

@implementation CDEThreeColumnSplitViewDelegate

#pragma mark Sizing Options
- (CGFloat)minWidthOfLeftView {
   return 100.0;
}

- (CGFloat)minWidthOfRightView {
   return 240.0;
}

- (CGFloat)maxWidthOfLeftView {
   return 350;
}

- (CGFloat)maxWidthOfRightView {
   return 350.0;
}

#pragma mark Properties
- (NSView *)leftView {
   return [self.splitView subviews][0];
}

- (NSView *)centerView {
   return [self.splitView subviews][1];
}

- (NSView *)rightView {
   return [self.splitView subviews][2];
}

@synthesize splitView;

#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)aSplitView canCollapseSubview:(NSView *)subview {
   self.splitView = aSplitView;
   return (subview != self.centerView);
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
   self.splitView = aSplitView;
   if(dividerIndex == 1) {
      return NSWidth(self.splitView.bounds) - [self maxWidthOfRightView];;
   }
   return [self minWidthOfLeftView];
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
   self.splitView = aSplitView;
   if(dividerIndex == 1) {
      return proposedMax - [self minWidthOfRightView];
   }
   if(dividerIndex == 0) {
      return [self maxWidthOfLeftView];
   }
   return proposedMax;
}

- (BOOL)splitView:(NSSplitView *)aSplitView shouldAdjustSizeOfSubview:(NSView *)subview {
   self.splitView = aSplitView;
   return (subview == self.centerView);
}

@end
