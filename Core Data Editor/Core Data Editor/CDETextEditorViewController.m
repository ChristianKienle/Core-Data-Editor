#import "CDETextEditorViewController.h"

@interface CDETextEditorViewController ()

#pragma mark - Properties
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation CDETextEditorViewController

#pragma mark Creating
- (instancetype)init {
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
