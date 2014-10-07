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
    NSDate *fileModDate;
    NSError *error;
    NSURL *url=[NSURL fileURLWithPath:self.storePath];
    [url getResourceValue:&fileModDate forKey:NSURLContentModificationDateKey error:&error];
    
    //Also look for: .sqlite-wal (write-ahead log).  Use most recent, although the wal should be most recent if found.
    NSURL *walUrl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@-wal",self.storePath]];
    NSDate *walDate;
    [walUrl getResourceValue:&walDate forKey:NSURLContentModificationDateKey error:&error];
    
    if ([fileModDate compare:walDate]==NSOrderedAscending) {
        fileModDate=walDate;
    }
    
    self.storeName=[NSString stringWithFormat:@"%@  (%@)",[self.storePath lastPathComponent], [self relativeDateStringForDate:fileModDate]];
    
    NSDate *modelModDate;
    NSURL *modelUrl=[NSURL fileURLWithPath:self.modelPath];
    [modelUrl getResourceValue:&modelModDate forKey:NSURLContentModificationDateKey error:&error];

    self.modelName=[NSString stringWithFormat:@"%@  (%@)",[self.modelPath lastPathComponent], [self relativeDateStringForDate:modelModDate]];
    
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

- (NSString *)relativeDateStringForDate:(NSDate *)date {
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    const int MONTH = 30 * DAY;
    
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [date timeIntervalSinceDate:now] * -1.0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    NSDateComponents *components = [calendar components:units fromDate:date toDate:now options:0];
    
    NSString *relativeString;
    
    if (delta < 0) {
        relativeString = @"In the future!";
        
    } else if (delta < 1 * MINUTE) {
        relativeString = (components.second == 1) ? @"One second ago" : [NSString stringWithFormat:@"%ld seconds ago",(long)components.second];
        
    } else if (delta < 2 * MINUTE) {
        relativeString =  @"a minute ago";
        
    } else if (delta < 45 * MINUTE) {
        relativeString = [NSString stringWithFormat:@"%ld minutes ago",(long)components.minute];
        
    } else if (delta < 90 * MINUTE) {
        relativeString = @"an hour ago";
        
    } else if (delta < 24 * HOUR) {
        relativeString = [NSString stringWithFormat:@"%ld hours ago",(long)components.hour];
        
    } else if (delta < 48 * HOUR) {
        relativeString = @"yesterday";
        
    } else if (delta < 30 * DAY) {
        relativeString = [NSString stringWithFormat:@"%ld days ago",(long)components.day];
        
    } else if (delta < 12 * MONTH) {
        relativeString = (components.month <= 1) ? @"One month ago" : [NSString stringWithFormat:@"%ld months ago",(long)components.month];
        
    } else {
        relativeString = (components.year <= 1) ? @"One year ago" : [NSString stringWithFormat:@"%ld years ago",(long)components.year];
        
    }
    
    return relativeString;
}

@end