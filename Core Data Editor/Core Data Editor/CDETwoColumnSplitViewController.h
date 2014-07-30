#import <Foundation/Foundation.h>

@interface CDETwoColumnSplitViewController : NSObject

#pragma mark - Creating
- (instancetype)initWithSplitView:(NSSplitView *)splitView
            indexOfResizeableView:(NSUInteger)indexOfResizeableView
            indexOfFixedSizeView:(NSUInteger)indexOfFixedSizeView;

@end
