#import "CDEModelChooserSheetController.h"
#import "CDEModelChooserItem.h"

@interface CDEModelChooserSheetController () <NSTableViewDelegate>

#pragma mark - Outlets
@property (nonatomic, weak) IBOutlet NSArrayController *modelItemsArrayController;

#pragma mark - Properties
@property (nonatomic, copy) CDEModelChooserSheetControllerCompletionHandler completionHandler;

#pragma mark - Actions
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@implementation CDEModelChooserSheetController

#pragma mark - Setting the displayed Model Chooser Items
- (void)setDisplayedModelChooserItems:(NSArray *)modelChooserItems {
    NSArray *items = modelChooserItems != nil ? modelChooserItems : @[];
    [self.modelItemsArrayController setContent:[NSMutableArray arrayWithArray:items]];
}

#pragma mark Actions
- (IBAction)ok:(id)sender {
    [NSApp endSheet:self.window];
    [self.window orderOut:sender];
    CDEModelChooserItem *selectedItem = [self.modelItemsArrayController.selectedObjects lastObject];
    (self.completionHandler)(CDEModelChooserSheetControllerResultOKButton, selectedItem);
    self.completionHandler = nil;
}

- (IBAction)cancel:(id)sender {
    [NSApp endSheet:self.window];
    [self.window orderOut:sender];
    (self.completionHandler)(CDEModelChooserSheetControllerResultCancelButton, nil);
    self.completionHandler = nil;
}

#pragma mark Creating
- (id)init {
   self = [super initWithWindowNibName:NSStringFromClass([self class])];
   if(self) {
      self.completionHandler = nil;
   }
   return self;
}

#pragma mark Running the Model Chooser
- (void)beginSheetModalForWindow:(NSWindow *)parentWindow completionHandler:(CDEModelChooserSheetControllerCompletionHandler)handler {
   if(self.completionHandler != nil) {
      return;
   }
   self.completionHandler = handler;
   [NSApp beginSheet:self.window modalForWindow:parentWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

#pragma mark NSTableViewDelegate
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
   if([[tableColumn identifier] isEqualToString:@"Icon"] == NO) {
      return;
   }
    
   CDEModelChooserItem *itemAtRow = (self.modelItemsArrayController.arrangedObjects)[rowIndex];
   NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:itemAtRow.URL.path];
   [cell setImage:icon];
}

@end
