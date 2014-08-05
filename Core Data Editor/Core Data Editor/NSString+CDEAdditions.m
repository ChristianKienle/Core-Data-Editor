#import "NSString+CDEAdditions.h"
#import "NSUserDefaults+CDEAdditions.h"

@implementation NSString (CDEAdditions)

#pragma mark - Human Readable Name
- (NSString *)humanReadableString_cde {
    // http://stackoverflow.com/questions/2559759/how-do-i-convert-camelcase-into-human-readable-names-in-java
    // source: https://github.com/mfornos/humanize
    NSString *pattern = @"(?<=[A-Z])(?=[A-Z][a-z])|(?<=[^A-Z])(?=[A-Z])|(?<=[A-Za-z])(?=[^A-Za-z])";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    NSString *result = [expression stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@" "];
    if(result != nil) {
        // capitalize first letter
        if(result.length > 0) {
            NSString *firstLetter = [result substringToIndex:1];
            NSString *tail = [result substringFromIndex:1];
            result = [[firstLetter uppercaseString] stringByAppendingString:tail];
        }
    }
    return result == nil ? self : result;
}

- (NSString *)humanReadableStringAccordingToUserDefaults_cde {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL humanize = defaults.showsNiceEntityAndPropertyNames_cde;
    return humanize ? [self humanReadableString_cde] : self;
}

#pragma mark - NSString to value for NSManagedObject

- (id)valueForAttributeType:(NSAttributeType)type dateFormatter:(NSDateFormatter *)dateFormatter numberFormatter_cde:(NSNumberFormatter *)numberFormatter {
    if([NSAttributeDescription isSupportedCSVAttributeType_cde:type] == NO) {
        NSLog(@"Error (in %@): type %li is not supported.", NSStringFromSelector(_cmd), type);
        return nil;
    }

    // Easy case
    if(type == NSStringAttributeType) {
        return self;
    }

    NSString *trimmed = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if(type == NSBooleanAttributeType) {
        // 1, true, TRUE, yes, YES => @YES
        // otherwise @NO
        NSSet *trueStrings = [NSSet setWithArray:@[@"1", @"true", @"yes", @"YES"]];
        return @([trueStrings containsObject:trimmed]);
    }

    // Dates
    if(type == NSDateAttributeType) {
        if(dateFormatter == nil) {
            NSLog(@"Error (in %@): date value expected but no date formatter given.", NSStringFromSelector(_cmd));
            return nil;
        }
        return [dateFormatter dateFromString:trimmed];
    }

    // Floats
    if(CDEIsFloatingPointAttributeType(type) || CDEIsIntegerAttributeType(type)) {
        if(numberFormatter == nil) {
            NSLog(@"Error (in %@): number value expected but no number formatter given.", NSStringFromSelector(_cmd));
            return nil;
        }
        return [numberFormatter numberFromString:trimmed];
    }

    return nil;
}

@end
