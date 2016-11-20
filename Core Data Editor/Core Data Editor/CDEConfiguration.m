#import "CDEConfiguration.h"
#import "NSURL+CDEAdditions.h"

@interface CDEConfiguration ()
@end

@implementation CDEConfiguration



- ( NSData * _Nonnull)data {
  NSMutableDictionary *dict = [NSMutableDictionary new];
  if(self.applicationBundlePath != nil) {
    dict[@"applicationBundlePath"] = self.applicationBundlePath;
  }
  if(self.autosaveInformationByEntityName != nil) {
    dict[@"autosaveInformationByEntityName"] = self.autosaveInformationByEntityName;
  }
  if(self.isMacApplication != nil) {
    dict[@"isMacApplication"] = self.isMacApplication;
  }
  if(self.modelPath != nil) {
    dict[@"modelPath"] = self.modelPath;
  }
  if(self.storePath != nil) {
    dict[@"storePath"] = self.storePath;
  }
  NSData *result = [NSKeyedArchiver archivedDataWithRootObject:dict];
  return result;
}

- (instancetype)initWithData:(NSData *_Nullable)data {
  self = [super init];
  NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  self.applicationBundlePath = dict[@"applicationBundlePath"];
  self.autosaveInformationByEntityName = dict[@"autosaveInformationByEntityName"];
  self.isMacApplication = dict[@"isMacApplication"];
  self.modelPath = dict[@"modelPath"];
  self.storePath = dict[@"storePath"];
  return self;
}
#pragma mark - Properties
- (NSURL*)applicationBundleURL {
  return [NSURL fileURLWithPath:self.applicationBundlePath];
}

- (NSURL*)storeURL {
  return [NSURL fileURLWithPath:self.storePath];
}
- (void)setStoreURL:(NSURL *)storeURL {
  self.storePath = storeURL.path;
}
- (NSURL *)modelURL {
  return [NSURL fileURLWithPath:self.modelPath];
}
- (void)setModelURL:(NSURL *)modelURL {
  self.modelPath = modelURL.path;
}

#pragma mark - Getting the only Configuration object
+ (NSSet *)keyPathsForValuesAffectingIsValid {
  return [NSSet setWithArray:@[@"modelPath", @"storePath"]];
}

- (BOOL)isValid {
  if(self.modelPath == nil || self.storePath == nil) {
    return NO;
  }
  return YES;
}

#pragma mark - Setting Bookmark Data in Batch
- (void)setApplicationBundleURL:(NSURL *)applicationBundleURL storeURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL {
  NSParameterAssert(storeURL);
  NSParameterAssert(modelURL);
  self.applicationBundlePath = applicationBundleURL.path;
  self.storePath = storeURL.path;
  self.modelPath = modelURL.path;
}

@end
