#import "CDEAboutWindowController.h"

@interface CDEAboutWindowController ()
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation CDEAboutWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSURL *aboutURL = [[NSBundle mainBundle] URLForResource:@"Credits" withExtension:@"rtf"];
    NSAttributedString *aboutText = [[NSAttributedString alloc] initWithURL:aboutURL documentAttributes:NULL];
    [[self.textView textStorage] appendAttributedString:aboutText];
}

@end
