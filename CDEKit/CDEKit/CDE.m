#import "CDE.h"
#import "CDE+Private.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

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

+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"CDEKit.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

- (void)present {
  // Make sure the view controller classes are all loaded
  [CDEEntitiesViewController class];
  [CDEManagedObjectsViewController class];
  [CDEManagedObjectViewController class];
  
  // Present the editor
  if(self.storyboard == nil) {
    self.storyboard = [UIStoryboard storyboardWithName:@"CDEEditor" bundle:[[self class] frameworkBundle]];
    self.navigationController = [self.storyboard instantiateInitialViewController];
  }
  
  UIApplication *application = [UIApplication sharedApplication];
  id<UIApplicationDelegate> delegate = application.delegate;
  self.managedObjectContext = [delegate performSelector:@selector(managedObjectContext)];
  self.managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
  
  UIWindow *window = application.keyWindow;
  NSLog(@"window: %@", window);
  [[window rootViewController] presentViewController:self.navigationController animated:YES completion:^{
    
  }];
}

#pragma mark - Presenting Errors
- (void)presentError:(NSError *)error {
  NSParameterAssert(error);
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
  [alert show];
}

@end
