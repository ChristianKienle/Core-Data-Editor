#import "CDEManagedObjectIDToStringValueTransformer.h"

#import "NSUserDefaults+CDEAdditions.h"


@implementation CDEManagedObjectIDToStringValueTransformer

#pragma mark - Register
+ (void)registerDefaultManagedObjectIDToStringValueTransformer {
    [NSValueTransformer setValueTransformer:[self new]
                                    forName:@"CDEManagedObjectIDToStringValueTransformer"];
}

#pragma mark NSValueTransformer
+ (Class)transformedValueClass { 
    return [NSString class]; 
}

+ (BOOL)allowsReverseTransformation { 
    return NO;
}

- (id)transformedValue:(id)objectID {
    if(objectID == nil) {
        return [NSString new];
    }
    
    if([objectID respondsToSelector:@selector(URIRepresentation)] == NO) {
        return [NSString string];
    }
    
    NSURL *URIRepresentation = [objectID URIRepresentation];
    NSArray *components = [URIRepresentation pathComponents];
    
    if(components.count < 2) {
        return [URIRepresentation absoluteString]; // Fallback
    }
    
    // Get the last one/two Components
    NSArray *importantComponents = [components subarrayWithRange:NSMakeRange(components.count - 2, 2)];
    BOOL displayEntity = [[NSUserDefaults standardUserDefaults] showsNameOfEntityInObjectIDColumn_cde];
    if(displayEntity == NO) {
        return [importantComponents lastObject];
    }
    return [importantComponents componentsJoinedByString:@"/"];
}

@end
