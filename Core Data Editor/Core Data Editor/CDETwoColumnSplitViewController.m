#import "CDETwoColumnSplitViewController.h"

@interface CDETwoColumnSplitViewController () <NSSplitViewDelegate>

#pragma mark - Properties
@property (nonatomic, weak) NSSplitView *splitView;
@property (nonatomic, assign) NSUInteger indexOfResizeableView;
@property (nonatomic, assign) NSUInteger indexOfFixedSizeView;

@end

@implementation CDETwoColumnSplitViewController

#pragma mark - Creating
- (instancetype)initWithSplitView:(NSSplitView *)splitView
            indexOfResizeableView:(NSUInteger)indexOfResizeableView
             indexOfFixedSizeView:(NSUInteger)indexOfFixedSizeView {
    NSParameterAssert(splitView);
    NSParameterAssert(splitView.subviews.count > MAX(indexOfFixedSizeView, indexOfResizeableView));
    NSParameterAssert(indexOfResizeableView != indexOfFixedSizeView);
    
    self = [super init];
    if(self) {
        self.splitView = splitView;
        self.splitView.delegate = self;
        self.indexOfResizeableView = indexOfResizeableView;
        self.indexOfFixedSizeView = indexOfFixedSizeView;
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"CDEInvalidInitializer" reason:nil userInfo:nil];
}

#pragma mark Sizing Options
- (CGFloat)minWidthOfFixedSizeView {
    return 100.0;
}

- (CGFloat)maxWidthOfFixedSizeView {
    return 350;
}

#pragma mark Properties
- (NSView *)fixedSizeView {
    return self.splitView.subviews[self.indexOfFixedSizeView];
}

- (NSView *)resizeableView {
    return self.splitView.subviews[self.indexOfResizeableView];
}

#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)aSplitView canCollapseSubview:(NSView *)subview {
    self.splitView = aSplitView;
    return NO;
}

- (BOOL)splitView:(NSSplitView *)aSplitView shouldAdjustSizeOfSubview:(NSView *)subview {
    self.splitView = aSplitView;
    return (subview == self.resizeableView);
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedCoordinate ofSubviewAt:(NSInteger)index
{
	return proposedCoordinate + [self minWidthOfFixedSizeView];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedCoordinate ofSubviewAt:(NSInteger)index
{
	return proposedCoordinate - [self minWidthOfFixedSizeView];
}

//- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
//{
//	NSRect newFrame = [sender frame]; // get the new size of the whole splitView
//	NSView *top = [self resizeableView];
//	NSRect topFrame = [top frame];
//	NSView *bottom = [self fixedSizeView];
//	NSRect bottomFrame = [bottom frame];
//
//	CGFloat dividerThickness = [sender dividerThickness];
//
//	topFrame.size.width = newFrame.size.width;
//
//	topFrame.size.height = newFrame.size.height - bottomFrame.size.height - dividerThickness;
//	topFrame.size.width = newFrame.size.width;
//	topFrame.origin.y = bottomFrame.size.height + dividerThickness;
//
////	[top setFrame:topFrame];
////	[bottom setFrame:bottomFrame];
//}

@end
