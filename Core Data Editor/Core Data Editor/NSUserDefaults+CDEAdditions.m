#import "NSUserDefaults+CDEAdditions.h"
#import "NSURL+CDEAdditions.h"

const struct CDEUserDefaultsKeys CDEUserDefaultsKeys = {
	.showsNameOfEntityInObjectIDColumn = @"CDEUserDefaultsShowsNameOfEntityInObjectIDColumn",
    .numberOfDecimals = @"CDEUserDefaultsNumberOfDecimals",
    .dateFormatterTimeStyle = @"CDEUserDefaultsDateFormatterTimeStyle",
    .dateFormatterDateStyle = @"CDEUserDefaultsDateFormatterDateStyle",
    .showsNiceEntityAndPropertyNames = @"CDEUserDefaultsShowsNiceEntityAndPropertyNames",
    .automaticallyResolvesValidationErrors = @"CDEUserDefaultsAutomaticallyResolvesValidationErrors",
    .buildProductsDirectoryBookmarkData = @"CDEUserDefaultsBuildProductsDirectoryBookmarkData",
    .simulatorDirectoryBookmarkData = @"CDEUserDefaultsSimulatorDirectoryBookmarkData",
    .applicationNeedsSetup = @"CDEUserDefaultsApplicationNeedsSetup",
    .firstLaunchDate = @"CDEUserDefaultsFirstLaunchDate",
    .openProjectBrowserOnLaunch = @"CDEUserDefaultsOpenProjectBrowserOnLaunch",
};

const struct CDEUserDefaultsNotifications CDEUserDefaultsNotifications = {
	.didChangeSimulatorDirectory = @"CDEUserDefaultsDidChangeSimulatorDirectoryNotification",
    .didChangeBuildProductsDirectory = @"CDEUserDefaultsDidChangeBuildProductsDirectoryNotification",
};

@implementation NSUserDefaults (CDEAdditions)

#pragma mark - Register Defaults
+ (void)registerCoreDataEditorDefaults_cde {
    NSDictionary *defaults = @{ CDEUserDefaultsKeys.showsNameOfEntityInObjectIDColumn : @NO,
                                CDEUserDefaultsKeys.numberOfDecimals : @2,
                                CDEUserDefaultsKeys.dateFormatterDateStyle : @(NSDateFormatterShortStyle),
                                CDEUserDefaultsKeys.dateFormatterTimeStyle : @(NSDateFormatterShortStyle),
                                CDEUserDefaultsKeys.showsNiceEntityAndPropertyNames : @YES,
                                CDEUserDefaultsKeys.automaticallyResolvesValidationErrors : @NO,
                                CDEUserDefaultsKeys.applicationNeedsSetup : @YES,
                                CDEUserDefaultsKeys.firstLaunchDate : [NSDate new],
                                CDEUserDefaultsKeys.openProjectBrowserOnLaunch : @YES,
                                };
    
    [[self standardUserDefaults] registerDefaults:defaults];
}

#pragma mark - Properties
- (BOOL)showsNameOfEntityInObjectIDColumn_cde {
    return [self boolForKey:CDEUserDefaultsKeys.showsNameOfEntityInObjectIDColumn];
}

- (void)setShowsNameOfEntityInObjectIDColumn_cde:(BOOL)showsNameOfEntityInObjectIDColumn {
    [self setBool:showsNameOfEntityInObjectIDColumn forKey:CDEUserDefaultsKeys.showsNameOfEntityInObjectIDColumn];
}
- (BOOL)opensProjectBrowserOnLaunch_cde
{
    return [self boolForKey:CDEUserDefaultsKeys.openProjectBrowserOnLaunch];
}
- (void)setOpenProjectBrowserOnLaunch_cde:(BOOL)opensProjectBrowserOnLaunch
{
    [self setBool:opensProjectBrowserOnLaunch forKey:CDEUserDefaultsKeys.openProjectBrowserOnLaunch];
}


- (NSInteger)numberOfDecimals_cde {
    return [self integerForKey:CDEUserDefaultsKeys.numberOfDecimals];
}

- (void)setNumberOfDecimals_cde:(NSInteger)numberOfDecimals {
    [self setNumberOfDecimals_cde:numberOfDecimals];
}

- (NSDateFormatterStyle)dateFormatterDateStyle_cde {
    return [self integerForKey:CDEUserDefaultsKeys.dateFormatterDateStyle];
}

- (void)setDateFormatterDateStyle_cde:(NSDateFormatterStyle)dateFormatterDateStyle {
    [self setInteger:dateFormatterDateStyle forKey:CDEUserDefaultsKeys.dateFormatterDateStyle];
}

- (NSDateFormatterStyle)dateFormatterTimeStyle_cde {
    return [self integerForKey:CDEUserDefaultsKeys.dateFormatterTimeStyle];
}

- (void)setDateFormatterTimeStyle_cde:(NSDateFormatterStyle)dateFormatterTimeStyle {
    [self setInteger:dateFormatterTimeStyle forKey:CDEUserDefaultsKeys.dateFormatterTimeStyle];
}

- (NSDateFormatter *)dateFormatter_cde {
    NSDateFormatterStyle timeStyle = [self dateFormatterTimeStyle_cde];
    NSDateFormatterStyle dateStyle = [self dateFormatterDateStyle_cde];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:dateStyle];
    [formatter setTimeStyle:timeStyle];

    return formatter;
}

- (NSNumberFormatter *)floatingPointNumberFormatter_cde {
    NSInteger decimalCount = [self numberOfDecimals_cde];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMinimumFractionDigits:0];
    [formatter setMaximumFractionDigits:(NSUInteger)decimalCount];
    [formatter setMinimumIntegerDigits:0];
    [formatter setMaximumIntegerDigits:42];
    return formatter;
}

- (void)setShowsNiceEntityAndPropertyNames_cde:(BOOL)showsNiceEntityAndPropertyNames {
    [self setBool:showsNiceEntityAndPropertyNames forKey:CDEUserDefaultsKeys.showsNiceEntityAndPropertyNames];
}

- (BOOL)showsNiceEntityAndPropertyNames_cde {
    return [self boolForKey:CDEUserDefaultsKeys.showsNiceEntityAndPropertyNames];
}

- (BOOL)automaticallyResolvesValidationErrors_cde {
    return [self boolForKey:CDEUserDefaultsKeys.automaticallyResolvesValidationErrors];
}

- (void)setAutomaticallyResolvesValidationErrors_cde:(BOOL)automaticallyResolvesValidationErrors_cde {
    [self setBool:automaticallyResolvesValidationErrors_cde forKey:CDEUserDefaultsKeys.automaticallyResolvesValidationErrors];
}

- (NSData *)buildProductsDirectoryBookmarkData_cde {
    return [self dataForKey:CDEUserDefaultsKeys.buildProductsDirectoryBookmarkData];
}

- (void)setBuildProductsDirectoryBookmarkData_cde:(NSData *)buildProductsDirectoryBookmarkData {
    [self setObject:buildProductsDirectoryBookmarkData forKey:CDEUserDefaultsKeys.buildProductsDirectoryBookmarkData];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDEUserDefaultsNotifications.didChangeBuildProductsDirectory object:self];
}

- (NSURL *)buildProductsDirectory_cde {
    NSData *bookmarkData = self.buildProductsDirectoryBookmarkData_cde;
    if(bookmarkData == nil) {
        return nil;
    }
    NSError *error = nil;
    NSURL *URL = [NSURL URLByResolvingBookmarkData:bookmarkData error_cde:&error];
    if(URL == nil) {
        NSLog(@"failed to resolve bookmark data for build directory: %@", error);
        return nil;
    }
    return URL;
}

- (void)setBuildProductsDirectory_cde:(NSURL *)URL {
    NSError *error = nil;
    NSData *bookmarkData = [URL bookmarkDataAndGetError_cde:&error];
    if(bookmarkData == nil) {
        NSLog(@"Failed to create bookmark data for selected build products directory '%@': %@", URL, error);
    }
    self.buildProductsDirectoryBookmarkData_cde = bookmarkData;
}


- (NSData *)simulatorDirectoryBookmarkData_cde {
    return [self dataForKey:CDEUserDefaultsKeys.simulatorDirectoryBookmarkData];
}

- (void)setSimulatorDirectoryBookmarkData_cde:(NSData *)simulatorDirectoryBookmarkData {
    [self setObject:simulatorDirectoryBookmarkData forKey:CDEUserDefaultsKeys.simulatorDirectoryBookmarkData];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDEUserDefaultsNotifications.didChangeSimulatorDirectory object:self];
}

- (NSURL *)simulatorDirectory_cde {
    NSData *bookmarkData = self.simulatorDirectoryBookmarkData_cde;
    if(bookmarkData == nil) {
        return nil;
    }
    NSError *error = nil;
    NSURL *URL = [NSURL URLByResolvingBookmarkData:bookmarkData error_cde:&error];
    
    if(URL == nil) {
        NSLog(@"failed to resolve bookmark data for build directory: %@", error);
        return nil;
    }
    return URL;
}

- (void)setSimulatorDirectory_cde:(NSURL *)URL {
    NSError *error = nil;
    NSData *bookmarkData = [URL bookmarkDataAndGetError_cde:&error];
    if(bookmarkData == nil) {
        NSLog(@"Failed to create bookmark data for selected build products directory '%@': %@", URL, error);
    }
    self.simulatorDirectoryBookmarkData_cde = bookmarkData;
}

- (void)setApplicationNeedsSetup_cde:(BOOL)applicationNeedsSetup {
    [self setBool:applicationNeedsSetup forKey:CDEUserDefaultsKeys.applicationNeedsSetup];
}

- (BOOL)applicationNeedsSetup_cde {
    return [self boolForKey:CDEUserDefaultsKeys.applicationNeedsSetup];
}

@end
