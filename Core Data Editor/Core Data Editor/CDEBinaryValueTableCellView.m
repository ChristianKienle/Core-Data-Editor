#import "CDEBinaryValueTableCellView.h"
#import "CDEBinaryDataToSizeValueTransformer.h"
#import "CDEDataValueToImageTransformer.h"
#import "CDEBinaryValuePreviewView.h"

@interface CDEBinaryValueTableCellView ()

#pragma mark - Properties
@property (nonatomic, assign) BOOL isInDropOperation;
@property (weak) IBOutlet NSMenuItem *saveAsMenuItem;
@property (weak) IBOutlet NSMenuItem *setToNilMenuItem;
@property (weak) IBOutlet CDEBinaryValuePreviewView *previewView;

@end

@implementation CDEBinaryValueTableCellView

#pragma mark - NSObject
+ (void)initialize {
    if(self == [CDEBinaryValueTableCellView class]) {
        [CDEBinaryDataToSizeValueTransformer registerDefaultCoreDataEditorBinaryDataToSizeValueTransformer];
        [NSValueTransformer setValueTransformer:[CDEDataValueToImageTransformer new] forName:@"CDEDataValueToImageTransformer"];
    }
}

- (IBAction)setObjectValueToNil:(id)sender {
    self.objectValue = nil;
    id<CDEBinaryValueTableCellViewDelegate> binaryDelegate = (id<CDEBinaryValueTableCellViewDelegate>)[self.textField delegate];
    [binaryDelegate binaryValueTextField:self.textField didChangeBinaryValue:nil];
}

#pragma mark - Properties
- (void)setIsInDropOperation:(BOOL)isInDropOperation {
    _isInDropOperation = isInDropOperation;
    self.previewView.hidden = isInDropOperation;
}

#pragma mark - NSTableCellView
- (IBAction)saveObjectValueAs:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.canCreateDirectories = YES;
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if(result != NSFileHandlingPanelOKButton) {
            return;
        }
        if([self.objectValue isKindOfClass:[NSData class]] == NO) {
            return;
        }
        NSURL *URL = panel.URL;
        [(NSData *)self.objectValue writeToURL:URL atomically:YES];
    }];
}

#pragma mark - NSTableCellView
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType, NSURLPboardType]];
    }
    
    return self;
}

- (void)awakeFromNib {
    self.isInDropOperation = NO;
    [self registerForDraggedTypes:@[NSFilenamesPboardType, NSURLPboardType]];
}

//- (void)setObjectValue:(id)objectValue {
//    [super setObjectValue:objectValue];
//    self.previewView.objectValue = self.objectValue;
//}

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
    self.previewView.objectValue = resultingObjectValue;
    [super setObjectValue:resultingObjectValue];
}

#pragma mark - NSMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu {
    BOOL canBeNiled = [self.objectValue isKindOfClass:[NSData class]];
    [self.setToNilMenuItem setEnabled:canBeNiled];    
    [self.saveAsMenuItem setEnabled:canBeNiled];
}

#pragma mark NSView
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(self.isInDropOperation) {
        [self drawDropZone];
    }
}

- (NSColor *)newBorderColor {
    NSColor *result = [NSColor colorWithCalibratedRed:0.242 green:0.361 blue:0.792 alpha:1.000];
    if(self.backgroundStyle == NSBackgroundStyleDark) {
        result = [NSColor colorWithCalibratedRed:0.888 green:0.902 blue:0.921 alpha:1.000];
    }
    return result;
}


- (NSColor *)newBackgroundColor {
    NSColor *result = [self newBorderColor];
    return [result colorWithAlphaComponent:0.4];
}

- (void)drawDropZone {
    CGFloat borderWidth = 2.0;
    CGFloat borderInset = borderWidth; //borderWidth + 1.0;
    
    NSRect dashedBorderRect = NSInsetRect(self.bounds, borderInset, borderInset);
    CGFloat cornerRadius = 5.0;
    NSBezierPath *dashedBorderPath = [NSBezierPath bezierPathWithRoundedRect:dashedBorderRect xRadius:cornerRadius yRadius:cornerRadius];
    
    
    [dashedBorderPath setLineWidth:borderWidth];
    

    NSColor *borderColor = [self newBorderColor];
    [borderColor setStroke];
    
    NSColor *backgroundColor = [self newBackgroundColor];
    [backgroundColor setFill];
    [dashedBorderPath fill];
    [dashedBorderPath stroke];
}

#pragma mark Drag and Drop Support
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSArray *classes = @[[NSURL class]];
    NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @YES};
    NSArray *fileURLs = [pasteboard readObjectsForClasses:classes options:options];
    if(fileURLs.count != 1) {
        self.isInDropOperation = NO;
        [self setNeedsDisplay:YES];
        return NSDragOperationNone;
    }
    self.isInDropOperation = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSArray *classes = @[[NSURL class]];
    NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @YES};
    NSArray *fileURLs = [pasteboard readObjectsForClasses:classes options:options];
    if(fileURLs.count != 1) {
        self.isInDropOperation = NO;
        [self setNeedsDisplay:YES];
        return NSDragOperationNone;
    }
    self.isInDropOperation = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender {
    self.isInDropOperation = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSArray *classes = @[[NSURL class]];
    NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @YES};
    NSArray *fileURLs = [pasteboard readObjectsForClasses:classes options:options];
    if(fileURLs.count != 1) {
        self.isInDropOperation = NO;
        [self setNeedsDisplay:YES];
        return NO;
    }
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSArray *classes = @[[NSURL class]];
    NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @YES};
    NSArray *fileURLs = [pasteboard readObjectsForClasses:classes options:options];
    NSURL *URL = [fileURLs lastObject];
    NSData *data = [NSData dataWithContentsOfFile:URL.path options:NSDataReadingMappedIfSafe error:NULL];
    self.objectValue = data;
    id<CDEBinaryValueTableCellViewDelegate> binaryDelegate = (id<CDEBinaryValueTableCellViewDelegate>)[self.textField delegate];
    [binaryDelegate binaryValueTextField:self.textField didChangeBinaryValue:data];
    [self setNeedsDisplay:YES];
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    self.isInDropOperation = NO;
    [self setNeedsDisplay:YES];
}

@end
