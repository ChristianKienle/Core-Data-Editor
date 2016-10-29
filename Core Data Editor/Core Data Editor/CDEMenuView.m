#import "CDEMenuView.h"
#import "CDEMenuWindowItem.h"
#import "CDEMenuItem.h"

@interface CDEMenuView ()

#pragma mark Properties
@property (nonatomic, strong) NSArray *itemViewControllers;

@end

@implementation CDEMenuView {
@private
  NSArray *_items;
}

#pragma mark Creating
- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if(self) {
    self.itemPrototype = nil;
    self.itemViewControllers = [NSArray array];
    _items = @[];
  }
  return self;
}

#pragma mark Properties
- (void)setItems:(NSArray *)newItems {
  if(_items != newItems) {
    _items = [newItems copy];
    [self recreateItemViewControllers];
    [self layoutEverything];
  }
}

- (NSArray *)items {
  return [_items copy];
}

#pragma mark Resizing
- (NSSize)minimumSize {
  if(self.items == nil || self.items.count == 0) {
    return NSMakeSize(100.0, 20.0);
  }
  
  CDEMenuWindowItem *itemController = [self.itemViewControllers lastObject];
  NSSize itemControllerSize = itemController.view.frame.size;
  NSSize result = NSMakeSize(200 /*NSWidth(self.bounds)*/, (self.items.count * itemControllerSize.height) + 2.0 * [self topAndBottomMargin]);
  return result;
}

- (void)sizeToFit {
  [self setFrameSize:[self minimumSize]];
  [self layoutEverything];
}

#pragma mark Private Methods
- (void)recreateItemViewControllers {
  for(CDEMenuWindowItem *itemViewController in self.itemViewControllers) {
    [itemViewController.view removeFromSuperview];
  }
  
  NSMutableArray *newItemViewControllers = [NSMutableArray array];
  for(CDEMenuItem *item in self.items) {
    CDEMenuWindowItem *newItemViewController = [CDEMenuWindowItem new];
    newItemViewController.item = item;
    [newItemViewController view];
    [self addSubview:newItemViewController.view];
    [newItemViewControllers addObject:newItemViewController];
  }
  self.itemViewControllers = newItemViewControllers;
}

- (void)layoutEverything {
  [self.itemViewControllers enumerateObjectsUsingBlock:^(id rawItemViewController, NSUInteger itemViewControllerIndex, BOOL *stop) {
    CDEMenuWindowItem *itemViewController = (CDEMenuWindowItem *)rawItemViewController;
    NSRect itemViewFrame = NSMakeRect(NSMinX([self interiorRect]), [self topAndBottomMargin] + (itemViewControllerIndex * [self itemViewSize].height), NSWidth([self interiorRect]), [self itemViewSize].height);
    [itemViewController.view setFrame:itemViewFrame];
  }];
}

- (NSSize)itemViewSize {
  if(self.itemPrototype == nil) {
    return NSZeroSize;
  }
  return [self.itemPrototype.view frame].size;
}

- (CGFloat)topAndBottomMargin {
  return 0.0;
}

- (CGFloat)leftAndRightMargin {
  return 0.0;
}

- (NSRect)interiorRect {
  return NSInsetRect(self.bounds, [self leftAndRightMargin], [self topAndBottomMargin]);
}

#pragma mark NSView
- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
}

- (BOOL)isFlipped {
  return YES;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
  [super resizeSubviewsWithOldSize:oldBoundsSize];
  [self layoutEverything];
}

@end
