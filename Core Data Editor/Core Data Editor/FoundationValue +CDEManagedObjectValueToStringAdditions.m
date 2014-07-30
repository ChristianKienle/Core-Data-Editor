#import "FoundationValue+CDEManagedObjectValueToStringAdditions.h"
#import "NSUserDefaults+CDEAdditions.h"

@implementation NSDate (CDEManagedObjectValueToStringAdditions)
- (NSString *)stringValueForCSVExport_cde {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *formatter = [defaults dateFormatter_cde];
    NSString *result = [formatter stringFromDate:self];
    return (result == nil ? @"" : result);
}
@end

@implementation NSNumber (CDEManagedObjectValueToStringAdditions)
- (NSString *)stringValueForCSVExport_cde {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumberFormatter *formatter = [defaults floatingPointNumberFormatter_cde];
    NSString *result = [formatter stringFromNumber:self];
    return (result == nil ? @"" : result);
}
@end

@implementation NSString (CDEManagedObjectValueToStringAdditions)
- (NSString *)stringValueForCSVExport_cde {
    return self;
}
@end

@implementation NSNull (CDEManagedObjectValueToStringAdditions)
- (NSString *)stringValueForCSVExport_cde {
    return @"NULL";
}
@end

@implementation NSManagedObjectID (CDEManagedObjectValueToStringAdditions)
- (NSString *)stringValueForCSVExport_cde {
    return [[self URIRepresentation] absoluteString];
}
@end
