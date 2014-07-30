#import "CDE.h"
#import <UIKit/UIKit.h>

@interface CDE ()

#pragma mark - Properties
@property (nonatomic, strong) UIStoryboard *storyboard;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation CDE

#pragma mark - Creating a Embedded Core Data Editor
+ (void)enableEmbeddedCoreDataEditor {
    UIApplication *application = [UIApplication sharedApplication];
    id<UIApplicationDelegate> delegate = application.delegate;
    if([delegate respondsToSelector:@selector(managedObjectContext)] == NO) {
        NSLog(@"No context found");
        return;
    }
    NSManagedObjectContext *context = [delegate performSelector:@selector(managedObjectContext)];
    UIWindow *window = application.windows[0];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    gestureRecognizer.numberOfTapsRequired = 4;
    
    [window addGestureRecognizer:gestureRecognizer];
    NSLog(@"windowz: %@", window);
    NSLog(@"context: %@", context);
}

+ (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"tap tap");
  NSBundle *b = [NSBundle mainBundle];
  NSLog(@"b: %@", b);
  [[self sharedCoreDataEditor] present];
}

#pragma mark - Working with the shared editor
+ (CDE *)sharedCoreDataEditor {
  static dispatch_once_t pred;
  static CDE *sharedCoreDataEditor = nil;
  dispatch_once(&pred, ^{
    sharedCoreDataEditor = [CDE new];
  });
  return sharedCoreDataEditor;
}

- (void)present {
  if(self.storyboard == nil) {
    self.storyboard = [UIStoryboard storyboardWithName:@"CDEEditor" bundle:nil];
    self.navigationController = [self.storyboard instantiateInitialViewController];
  }
  UIApplication *application = [UIApplication sharedApplication];
  id<UIApplicationDelegate> delegate = application.delegate;
  UIWindow *window = application.keyWindow;
  NSLog(@"window: %@", window);
}


@end
