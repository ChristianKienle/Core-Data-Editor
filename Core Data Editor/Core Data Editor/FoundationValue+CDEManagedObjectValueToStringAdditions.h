#import <Foundation/Foundation.h>

@interface NSDate (CDEManagedObjectValueToStringAdditions)
- (NSString *)stringValueForCSVExport_cde;
@end

@interface NSNumber (CDEManagedObjectValueToStringAdditions)
- (NSString *)stringValueForCSVExport_cde;
@end

@interface NSString (CDEManagedObjectValueToStringAdditions)
- (NSString *)stringValueForCSVExport_cde;
@end

@interface NSNull (CDEManagedObjectValueToStringAdditions)
- (NSString *)stringValueForCSVExport_cde;
@end

@interface NSManagedObjectID (CDEManagedObjectValueToStringAdditions)
- (NSString *)stringValueForCSVExport_cde;
@end
