#import "NSURL+CDEApplicationAnalyzer.h"

@implementation NSURL (CDEApplicationAnalyzer)

#pragma mark - Application Bundle Detection
- (BOOL)isApplicationBundleURL_cde {
    NSString *applicationBundleUTI = @"com.apple.application-bundle";
    NSError *error = nil;
    NSString *bundleUTI = [[NSWorkspace sharedWorkspace] typeOfFile:self.path error:&error];
    if(bundleUTI == nil) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    return [[NSWorkspace sharedWorkspace] type:bundleUTI conformsToType:applicationBundleUTI];
}

@end
