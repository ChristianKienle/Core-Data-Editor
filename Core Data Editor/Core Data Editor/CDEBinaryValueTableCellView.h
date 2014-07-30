#import <Cocoa/Cocoa.h>

@protocol CDEBinaryValueTableCellViewDelegate <NSTextFieldDelegate>

- (void)binaryValueTextField:(NSTextField *)textField didChangeBinaryValue:(NSData *)binaryValue;

@end

@interface CDEBinaryValueTableCellView : NSTableCellView
@end
