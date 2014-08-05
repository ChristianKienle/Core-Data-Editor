#import "NSWorkspace+CDEAdditions.h"
#import "NSURL+CDEAdditions.h"

@implementation NSWorkspace (CDEAdditions)

#pragma mark - Opening App Specific URLs
- (void)openCreateProjectTutorial_cde {
    [self openURL:[NSURL URLForCreateProjectTutorial_cde]];
}

- (void)openSupportWebsite_cde {
    [self openURL:[NSURL URLForSupportWebsite_cde]];
}

@end
