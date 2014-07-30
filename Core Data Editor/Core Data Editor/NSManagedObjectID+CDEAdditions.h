#import <CoreData/CoreData.h>

@interface NSURL (NSManagedObjectID_CDEAdditions)
- (NSString *)humanReadableRepresentationByInterpretingAsTemporaryObjectURL:(BOOL)isTemporary hideEntityName_cde:(BOOL)hideEntityName;
@end

@interface NSManagedObjectID (CDEAdditions)
- (NSString *)stringRepresentationForDisplay_cde;
- (NSString *)humanReadableRepresentationByHidingEntityName_cde:(BOOL)hideEntityName;
@end
