#import "CMKBindingSupport.h"

@implementation CMKBindingSupport

+ (BOOL)valueIsMultipleValuesMarker:(id)value {
    return (value == NSMultipleValuesMarker);
}

+ (BOOL)valueIsNoSelectionMarker:(id)value {
    return (value == NSNoSelectionMarker);
}

+ (BOOL)valueNotApplicableMarker:(id)value {
    return (value == NSNotApplicableMarker);
}

+ (BOOL)valueIsSingleValueMarker:(id)value {
    return ([self valueIsMultipleValuesMarker:value] == NO && [self valueIsNoSelectionMarker:value] == NO && [self valueNotApplicableMarker:value] == NO);
}

@end
