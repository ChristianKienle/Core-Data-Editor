#import <Foundation/Foundation.h>

@class CDEDropApplicationViewController;
@protocol CDEDropModelViewControllerDelegate <NSObject>

@required
- (void)dropModelViewController:(CDEDropApplicationViewController *)controller didReceiveModelURL:(NSURL *)modelURL locatedInApplicationBundleURL:(NSURL *)applicationBundleURL;

@end
