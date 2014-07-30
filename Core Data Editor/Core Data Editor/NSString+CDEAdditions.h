#import <Foundation/Foundation.h>

@interface NSString (CDEAdditions)

#pragma mark - Human Readable Name
- (NSString *)humanReadableString_cde;
- (NSString *)humanReadableStringAccordingToUserDefaults_cde;

#pragma mark - NSString to value for NSManagedObject
- (id)valueForAttributeType_cde:(NSAttributeType)type; // is using the date and number formatter from the user defaults
- (id)valueForAttributeType:(NSAttributeType)type dateFormatter:(NSDateFormatter *)dateFormatter numberFormatter_cde:(NSNumberFormatter *)numberFormatter;

@end
