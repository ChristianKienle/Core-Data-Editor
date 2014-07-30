#import <Foundation/Foundation.h>

@interface CDEConfigurationSummaryRequest : NSObject {
   @private
   NSURL *applicationBundleURL;
   NSURL *storeURL;
}

#pragma mark Creating
- (id)initWithApplicationBundleURL:(NSURL *)initApplicationBundleURL storeURL:(NSURL *)initStoreURL;

#pragma mark Properties
@property (nonatomic, readonly, copy) NSURL *applicationBundleURL;
@property (nonatomic, readonly, copy) NSURL *storeURL;

@end
