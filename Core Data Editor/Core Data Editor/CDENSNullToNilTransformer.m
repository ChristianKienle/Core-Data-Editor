#import "CDENSNullToNilTransformer.h"

@implementation CDENSNullToNilTransformer

#pragma mark NSValueTransformer
+ (Class)transformedValueClass {
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    if(value == nil) {
        return nil;
    }
    
    if([NSNull null] == value) {
        return nil;
    }
    
    return value;
}

- (id)reverseTransformedValue:(id)value {
    if(value == nil) {
        return nil;
    }
    return value;
}

@end
