#import "NSManagedObjectID+CDEAdditions.h"

@implementation NSURL (NSManagedObjectID_CDEAdditions)

- (NSString *)humanReadableRepresentationByInterpretingAsTemporaryObjectURL:(BOOL)isTemporary hideEntityName_cde:(BOOL)hideEntityName {
    NSArray *components = [self pathComponents];
    
    if(components.count < 2) {
        return [self absoluteString]; // Fallback
    }
    
    // Get the last one/two Components
    NSArray *importantComponents = [components subarrayWithRange:NSMakeRange(components.count - 2, 2)];
    
    NSString *entityName = importantComponents[0];
    NSString *ID = importantComponents[1];
    NSString *readableID = ID;
    if(isTemporary) {
        NSArray *IDComponentns = [ID componentsSeparatedByString:@"-"];
        readableID = [@"t…" stringByAppendingString:[IDComponentns lastObject]];
    }
    
    NSMutableString *result = [NSMutableString new];
    
    if(hideEntityName == NO) {
        [result appendFormat:@"%@/", entityName];
    }
    [result appendString:readableID];
    return result;
}

@end

@implementation NSManagedObjectID (CDEAdditions)

- (NSString *)stringRepresentationForDisplay_cde {
    BOOL displayEntity = [[NSUserDefaults standardUserDefaults] showsNameOfEntityInObjectIDColumn_cde];
    return [self humanReadableRepresentationByHidingEntityName_cde:!displayEntity];
}

- (NSString *)humanReadableRepresentationByHidingEntityName_cde:(BOOL)hideEntityName {
    return [self.URIRepresentation humanReadableRepresentationByInterpretingAsTemporaryObjectURL:self.isTemporaryID hideEntityName_cde:hideEntityName];
}

@end
