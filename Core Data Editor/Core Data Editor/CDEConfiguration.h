@interface CDEConfiguration : NSObject

#pragma mark - Properties
@property (nullable, readonly) NSURL *storeURL, *modelURL, *applicationBundleURL;
@property (nullable, copy) NSString *applicationBundlePath;
@property (nullable, strong) NSDictionary *autosaveInformationByEntityName;
@property (nullable, copy) NSNumber *isMacApplication;
@property (nullable, copy) NSString *modelPath;
@property (nullable, copy) NSString *storePath;

#pragma mark - Properties
@property (nonatomic, readonly, getter = isValid) BOOL isValid;

#pragma mark - Setting URLs
- (void)setApplicationBundleURL:(nullable NSURL *)applicationBundleURL storeURL:(nullable NSURL *)storeURL modelURL:(nullable NSURL *)modelURL;

- (NSData * _Nonnull )data;
- (nullable instancetype)initWithData:(NSData * _Nullable )data;

@end
