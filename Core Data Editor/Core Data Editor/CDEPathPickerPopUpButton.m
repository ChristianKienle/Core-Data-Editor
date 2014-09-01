#import "CDEPathPickerPopUpButton.h"

@implementation CDEPathPickerPopUpButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    return self;
}

#pragma mark - Nib
- (void)awakeFromNib {
    [super awakeFromNib];
    [self createDefaultMenuItems];
    self.URL = nil;
}

#pragma mark - Properties
- (void)setURL:(NSURL *)URL {
    _URL = URL;
    if(self.URL == nil) {
        [self showPlaceholderInBuildDirectoryPopUpButton];
    } else {
        [self showURLInBuildDirectoryPopUpButton:self.URL];
    }
}

#pragma mark - Helper
- (void)createDefaultMenuItems {
    NSMenuItem *directoryItem = [self.menu insertItemWithTitle:@"No Directory Set" action:NULL keyEquivalent:@"" atIndex:0];
    directoryItem.tag = 0;
    [directoryItem setEnabled:NO];
    [self.menu insertItem:[NSMenuItem separatorItem] atIndex:1];
    NSMenuItem *otherItem = [self.menu insertItemWithTitle:@"Other…" action:@selector(otherItemSelected:) keyEquivalent:@"" atIndex:2];
    otherItem.target = self;
}

- (void)otherItemSelected:(NSMenuItem *)sender {
    self.otherItemSelectedHandler ? self.otherItemSelectedHandler(self) : nil;
    [self selectItemAtIndex:0];
}

- (void)showPlaceholderInBuildDirectoryPopUpButton {
    NSMenuItem *item = [self.menu itemWithTag:0];
    item.title = @"No Directory Set";
    [item setEnabled:NO];
    [item setImage:nil];
    [self selectItemWithTag:0];
}

- (void)showURLInBuildDirectoryPopUpButton:(NSURL *)URL {
    NSMenuItem *item = [self.menu itemWithTag:0];
    item.title = [URL lastPathComponent];
    [item setEnabled:YES];
    NSImage *directoryImage = [NSImage imageNamed:NSImageNameFolder];
    directoryImage.size = NSMakeSize(16, 16);
    [item setImage:directoryImage];
    [self selectItemWithTag:0];
}

@end
