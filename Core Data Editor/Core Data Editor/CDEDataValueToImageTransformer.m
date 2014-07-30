#import "CDEDataValueToImageTransformer.h"

@implementation CDEDataValueToImageTransformer

#pragma mark NSValueTransformer
+ (Class)transformedValueClass {
    return [NSImage class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if(value == nil) {
        return [NSImage imageNamed:@"NSApplicationIcon"];
    }
    
    if([NSNull null] == value) {
        return [NSImage imageNamed:@"NSApplicationIcon"];
    }
    
//    if([NSImageRep canInitWithData:value] == NO) {
//        return [NSImage imageNamed:@"NSApplicationIcon"];
//    }
    
    NSImage *image = [[NSImage alloc] initWithData:value];
    if(image == nil) {
        return [NSImage imageNamed:@"NSApplicationIcon"];
    }
    return image;
}

@end
