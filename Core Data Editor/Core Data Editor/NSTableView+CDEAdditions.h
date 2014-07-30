#import <Cocoa/Cocoa.h>

@interface NSTableView (CDEAdditions)

#pragma mark - Convenience
- (void)removeAllTableColumns_cde;
- (void)addTableColumns_cde:(NSArray *)tableColumns;

#pragma mark - Workaround
// The methods below should be used instead of their "native" counterparts. This is what I observed with their counterparts:
// - I begin editing a text field in a row subview.
// - Then I click on the table header of a column to change the sorting of the table view.
// - This causes the underlying date to be re-arranged.
// - At some point endEditing is called
// - For some reason rowForView/columnForView return -1
// - When using the methods below who actually are implemented by using public methods of NSTableView this does not happen.
- (NSInteger)rowForView_cde:(NSView *)view;
- (NSInteger)columnForView_cde:(NSView *)view;

@end
