#import "CDENameToNameForDisplayValueTransformer.h"

@implementation CDENameToNameForDisplayValueTransformer

#pragma mark - Convenience
+ (void)registerDefaultCoreDataEditorNameToNameForDisplayValueTransformer {
    [NSValueTransformer setValueTransformer:[self new] forName:[self name]];
}

#pragma mark Metadata
+ (NSString *)name {
    return @"CDENameToNameForDisplayValueTransformer";
}

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if(value == nil) {
        return nil;
    }
    return [value humanReadableStringAccordingToUserDefaults_cde];
}
@end
