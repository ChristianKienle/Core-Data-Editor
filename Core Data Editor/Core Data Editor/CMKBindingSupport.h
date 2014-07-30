#import <Cocoa/Cocoa.h>

@interface CMKBindingSupport : NSObject

+ (BOOL)valueIsMultipleValuesMarker:(id)value;
+ (BOOL)valueIsNoSelectionMarker:(id)value;
+ (BOOL)valueNotApplicableMarker:(id)value;
+ (BOOL)valueIsSingleValueMarker:(id)value;

@end
