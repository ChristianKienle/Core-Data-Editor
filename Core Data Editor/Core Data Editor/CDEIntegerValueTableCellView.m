#import "CDEIntegerValueTableCellView.h"

@implementation CDEIntegerValueTableCellView

#pragma mark - NSTableCellView
- (void)setObjectValue:(id)objectValue {
    id resultingObjectValue = nil;
    
    if(objectValue == [NSNull null]) {
        resultingObjectValue = nil;
        [self.textField.cell setPlaceholderString:@"nil"];
    }
    else {
        [self.textField.cell setPlaceholderString:nil];
        resultingObjectValue = objectValue;
    }
    [super setObjectValue:resultingObjectValue];
}
@end
