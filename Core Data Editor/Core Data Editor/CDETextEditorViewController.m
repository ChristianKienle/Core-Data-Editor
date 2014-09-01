#import "CDETextEditorViewController.h"

@interface CDETextEditorViewController ()

#pragma mark - Properties
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation CDETextEditorViewController

#pragma mark Creating
<<<<<<< HEAD
- (instancetype)init {
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
=======
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (instancetype)init {
    self = [self initWithNibName:@"CDETextEditorViewController" bundle:nil];
>>>>>>> 65ba89d7421433954f4d462d9419443797f8901d
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
