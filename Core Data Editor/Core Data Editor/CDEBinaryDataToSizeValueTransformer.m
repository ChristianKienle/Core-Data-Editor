#import "CDEBinaryDataToSizeValueTransformer.h"

@implementation CDEBinaryDataToSizeValueTransformer

#pragma mark - Convenience
+ (void)registerDefaultCoreDataEditorBinaryDataToSizeValueTransformer {
    [NSValueTransformer setValueTransformer:[self new] forName:[self name]];
}

#pragma mark Metadata
+ (NSString *)name {
   return @"CDEBinaryDataToSizeValueTransformer";
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
    if(value == [NSNull null]) {
        return nil;
    }
    
    if(value == nil || [value respondsToSelector:@selector(length)] == NO) {
        return @0;
    }
    
    NSUInteger length = [value length];
    return [NSByteCountFormatter stringFromByteCount:length countStyle:NSByteCountFormatterCountStyleMemory];
//    return @(length);
}

@end
