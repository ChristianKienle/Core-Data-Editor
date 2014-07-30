#import "NSDictionary+CDEInfoDictionaryAdditions.h"

@implementation NSDictionary (CDEInfoDictionaryAdditions)

#pragma mark - Determine the application type of an Info Dictionary
- (CDEApplicationType)applicationType_cde {
    // self is empty => Unknown
    if(self.count == 0) {
        return CDEApplicationTypeUnknown;
    }
    
    NSString *iOSKey = @"LSRequiresIPhoneOS";
    BOOL isOSXApplication = (self[iOSKey] == nil);

    return isOSXApplication ? CDEApplicationTypeOSX : CDEApplicationTypeiOS;
}

@end
