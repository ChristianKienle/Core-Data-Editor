#import "CDEPathActionLabelController.h"

@interface CDEPathActionLabelController ()

#pragma mark - Outlets
@property (nonatomic, weak) IBOutlet NSTextField *pathTextField;
@property (nonatomic, weak) IBOutlet NSButton *revealPathButton;

#pragma mark - Actions
- (IBAction)revealPath:(id)sender;

@end

@implementation CDEPathActionLabelController

#pragma mark - Actions
- (IBAction)revealPath:(id)sender {
    [[NSWorkspace sharedWorkspace] selectFile:self.pathTextField.stringValue inFileViewerRootedAtPath:@""];
}

#pragma mark NibAwaking
- (void)awakeFromNib {
   if([super respondsToSelector:@selector(awakeFromNib)]) {
      [super awakeFromNib];
   }
   self.revealPathButton.target = self;
   self.revealPathButton.action = @selector(revealPath:);
   [self setPath:[NSString string]]; // Hide everything
}

#pragma mark Working with the displayed Path
- (void)setPath:(NSString *)newPath {
   NSString *resultingPath = newPath;
   if(resultingPath == nil) {
      resultingPath = [NSString string];
   }
   BOOL pathTextFieldAndButtonHidden = (resultingPath.length == 0);
   self.pathTextField.stringValue = resultingPath;
   [self.pathTextField setHidden:pathTextFieldAndButtonHidden];
   [self.revealPathButton setHidden:pathTextFieldAndButtonHidden];
}

@end
