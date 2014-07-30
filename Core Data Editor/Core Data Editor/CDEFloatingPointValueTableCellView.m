#import "CDEFloatingPointValueTableCellView.h"
#import "NSUserDefaults+CDEAdditions.h"

@implementation CDEFloatingPointValueTableCellView

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

#pragma mark - Updating the UI
- (void)updateFormatter {
    NSInteger decimalCount = [[NSUserDefaults standardUserDefaults] numberOfDecimals_cde];
    NSNumberFormatter *formatter = [[self.textField formatter] copy];
    [formatter setMinimumFractionDigits:0];
    [formatter setMaximumFractionDigits:(NSUInteger)decimalCount];
    [formatter setMinimumIntegerDigits:0];
    [formatter setMaximumIntegerDigits:42];

    self.textField.formatter = formatter;
}

@end
