#import "NSString+CDEPersistentStore.h"

@implementation NSString (CDEPersistentStore)

#pragma mark - Properties
- (CDESupportedStoreType)supportedStoreType_cde {
    if([self isEqualToString:NSSQLiteStoreType]) {
        return CDESupportedStoreTypeSQLite;
    }
    if([self isEqualToString:NSXMLStoreType]) {
        return CDESupportedStoreTypeXML;
    }
    if([self isEqualToString:NSBinaryStoreType]) {
        return CDESupportedStoreTypeBinary;
    }
    return CDESupportedStoreTypeUnknown;
}

@end
