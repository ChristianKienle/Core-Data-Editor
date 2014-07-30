#import <Foundation/Foundation.h>

@class CDEDropStoreViewController;
@protocol CDEDropStoreViewControllerDelegate <NSObject>
@required
- (void)dropStoreViewController:(CDEDropStoreViewController *)controller didChangeStoreURL:(NSURL *)storeURL;
@end
