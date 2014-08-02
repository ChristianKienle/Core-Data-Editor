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
- (void)enableEmbeddedCoreDataEditorWithMainContext:(NSManagedObjectContext *)mainContext {
  NSParameterAssert(mainContext);
  self.managedObjectContext = mainContext;

  UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleTapGesture:)];
  gestureRecognizer.numberOfTapsRequired = 4;
    
  [[self applicationWindow] addGestureRecognizer:gestureRecognizer];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
  [self present];
}

#pragma mark - Working with the shared editor
+ (instancetype)sharedCoreDataEditor {
  static dispatch_once_t pred;
  static id sharedCoreDataEditor = nil;
  dispatch_once(&pred, ^{
    sharedCoreDataEditor = [self new];
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
  if(self.storyboard == nil) {
    self.storyboard = [UIStoryboard storyboardWithName:@"CDEEditor" bundle:[[self class] frameworkBundle]];
    self.navigationController = [self.storyboard instantiateInitialViewController];
  }
  
  self.managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
  
  [[[self applicationWindow] rootViewController] presentViewController:self.navigationController
                                                              animated:YES
                                                            completion:NULL];
}

- (UIWindow *)applicationWindow
{
  return [UIApplication sharedApplication].windows[0];
}

#pragma mark - Presenting Errors
- (void)presentError:(NSError *)error {
  NSParameterAssert(error);
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                  message:[error localizedRecoverySuggestion]
                                                 delegate:nil
                                        cancelButtonTitle:@"Dismiss"
                                        otherButtonTitles:nil];
  [alert show];
}

@end
