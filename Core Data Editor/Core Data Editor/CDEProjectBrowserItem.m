#import "CDEProjectBrowserItem.h"

@interface CDEProjectBrowserItem ()

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSString *storePath;
@property (nonatomic, copy, readwrite) NSString *storeName;

@property (nonatomic, copy, readwrite) NSString *modelPath;
@property (nonatomic, copy, readwrite) NSString *modelName;

@property (nonatomic, copy, readwrite) NSString *projectName;

@property (nonatomic, strong, readwrite) NSImage *icon;

@end

@implementation CDEProjectBrowserItem : NSObject

#pragma mark - Creating
- (instancetype)initWithStorePath:(NSString *)storePath modelPath:(NSString *)modelPath {
    self = [super init];
    if(self) {
        self.storePath = storePath;
        self.modelPath = modelPath;
        [self createNamesAndIcon];
    }
    return self;
}

- (instancetype)init {
    return [self initWithStorePath:@"" modelPath:@""];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: store path = %@, model path = %@", [super description], self.storePath, self.modelPath];
}

- (void)createNamesAndIcon {
    self.storeName = [self.storePath lastPathComponent];
    self.modelName = [self.modelPath lastPathComponent];
    self.projectName = [self.modelName stringByDeletingPathExtension];
    NSArray *components = [self.modelPath pathComponents];
    [components enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
        if([[component pathExtension] isEqualToString:@"app"]) {
            self.projectName = [component stringByDeletingPathExtension];
            NSArray *appBundleComponents = [components subarrayWithRange:NSMakeRange(0, idx+1)];
            NSURL *appBundleURL = [NSURL fileURLWithPathComponents:appBundleComponents];
            self.icon = [self iconFromBundleAtURL:appBundleURL];
            *stop = YES;
        }
    }];
}

- (NSImage *)iconFromBundleAtURL:(NSURL *)bundleURL {
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    NSDictionary *infoDictionary = bundle.infoDictionary;
    NSDictionary *icons = infoDictionary[@"CFBundleIcons"];
    NSDictionary *primaryIcon = icons[@"CFBundlePrimaryIcon"];
    NSArray *iconFiles = primaryIcon[@"CFBundleIconFiles"];
    NSString *iconName = iconFiles.lastObject;

    if(iconName == nil) {
        return [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericApplicationIcon)];
    }
    
    NSURL *iconURL = [bundleURL URLByAppendingPathComponent:iconName isDirectory:NO];
    
    NSFileManager *fileManager = [NSFileManager new];
    
    if([fileManager fileExistsAtPath:iconURL.path] == NO) {
        return [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericApplicationIcon)];
    }
    
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:iconURL];
    return image;
}

@end