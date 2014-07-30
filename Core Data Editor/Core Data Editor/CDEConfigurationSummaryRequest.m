#import "CDEConfigurationSummaryRequest.h"

@interface CDEConfigurationSummaryRequest ()

#pragma mark Properties
@property (nonatomic, readwrite, copy) NSURL *applicationBundleURL;
@property (nonatomic, readwrite, copy) NSURL *storeURL;

@end

@implementation CDEConfigurationSummaryRequest

#pragma mark Properties
@synthesize applicationBundleURL, storeURL;

#pragma mark Creating
- (id)initWithApplicationBundleURL:(NSURL *)initApplicationBundleURL storeURL:(NSURL *)initStoreURL {
   if(initStoreURL == nil || initApplicationBundleURL == nil) {
      self = nil;
      return nil;
   }
   self = [super init];
   if(self) {
      self.applicationBundleURL = initApplicationBundleURL;
      self.storeURL = initStoreURL;
   }
   return self;
}

- (id)init {
   return [self initWithApplicationBundleURL:nil storeURL:nil];
}

@end
