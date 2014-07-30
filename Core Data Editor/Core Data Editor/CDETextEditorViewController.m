#import "CDETextEditorViewController.h"

@interface CDETextEditorViewController ()

#pragma mark - Properties
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation CDETextEditorViewController

#pragma mark Creating
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

- (instancetype)init {
    self = [super initWithNibName:@"CDETextEditorViewController" bundle:nil];
    if(self) {
    }
    return self;
}

#pragma mark - NSViewController
- (void)loadView {
    [super loadView];
    self.textView.font = [NSFont fontWithName:@"Monaco" size:12];
}
@end
