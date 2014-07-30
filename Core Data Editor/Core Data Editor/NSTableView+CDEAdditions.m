#import "NSTableView+CDEAdditions.h"

@implementation NSTableView (CDEAdditions)

#pragma mark - Convenience
- (void)removeAllTableColumns_cde {
    while([[self tableColumns] count] > 0) {
        NSTableColumn *tableColumn = [[self tableColumns] lastObject];
        [self removeTableColumn:tableColumn];
    }
}

- (void)addTableColumns_cde:(NSArray *)tableColumns {
    for(NSTableColumn *column in tableColumns) {
        [self addTableColumn:column];
    }
}

#pragma mark - Workaround
- (NSInteger)rowForView_cde:(NSView *)view {
    if(view == nil) {
        NSLog(@"%@ called with a nil view.", NSStringFromSelector(_cmd));
        return -1;
    }
    NSRect viewBoundsInLocalCoordinateSystem = [self convertRect:view.bounds fromView:view];
    NSPoint centerInView = NSMakePoint(NSMidX(viewBoundsInLocalCoordinateSystem), NSMidY(viewBoundsInLocalCoordinateSystem));
    NSInteger result = [self rowAtPoint:centerInView];
    return result;
}

- (NSInteger)columnForView_cde:(NSView *)view {
    if(view == nil) {
        NSLog(@"%@ called with a nil view.", NSStringFromSelector(_cmd));
        return -1;
    }
    NSRect viewBoundsInLocalCoordinateSystem = [self convertRect:view.bounds fromView:view];
    NSPoint centerInView = NSMakePoint(NSMidX(viewBoundsInLocalCoordinateSystem), NSMidY(viewBoundsInLocalCoordinateSystem));
    NSInteger result = [self columnAtPoint:centerInView];
    return result;
}

@end
