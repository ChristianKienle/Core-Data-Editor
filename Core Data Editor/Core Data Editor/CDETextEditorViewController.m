#import "CDETextEditorViewController.h"

@interface CDETextEditorViewController ()

#pragma mark - Properties
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation CDETextEditorViewController

#pragma mark Creating
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (instancetype)init {
    self = [self initWithNibName:@"CDETextEditorViewController" bundle:nil];
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
