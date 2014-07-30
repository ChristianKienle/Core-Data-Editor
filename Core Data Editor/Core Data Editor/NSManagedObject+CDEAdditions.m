#import "NSManagedObject+CDEAdditions.h"
#import "NSError+CDEValidation.h"
#import "NSUserDefaults+CDEAdditions.h"
#import "FoundationValue+CDEManagedObjectValueToStringAdditions.h"

@implementation NSManagedObject (CDEAdditions)

- (NSArray *)validationErrors_cde {
    BOOL isValid = YES;
    NSError *error = nil;
    if(self.isInserted) {
        isValid = [self validateForInsert:&error];
    }
    if(self.isUpdated) {
        isValid = [self validateForUpdate:&error];
    }
    if(self.isDeleted) {
        isValid = [self validateForDelete:&error];
    }
    if(isValid) {
        return nil;
    }
    if(error == nil) {
        return nil;
    }
    if(error.containsDetailedErrors_cde == NO) {
        return @[error];
    }
    return error.detailedErrors_cde;
}

#pragma mark - CSV
- (NSArray *)CSVValuesForAttributeNames_cde:(NSArray *)attributeNames {
    NSMutableArray *result = [NSMutableArray new];
    for(NSString *attributeName  in attributeNames) {
        id value = [self valueForKey:attributeName];
        if(value == nil) {
            value = [NSNull null];
        }
        NSString *stringValue = [value stringValueForCSVExport_cde];
        [result addObject:stringValue];
    }
    return result;
}

#pragma mark - Creating
+ (instancetype)newManagedObjectWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context makeInsertedObjectValid_cde:(BOOL)makeInsertedObjectValid {
    NSManagedObject *result = [[self alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    if(makeInsertedObjectValid) {
        [context makeManagedObjectValid:result];
    }
    return result;
}

+ (instancetype)newManagedObjectWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext_cde:(NSManagedObjectContext *)context {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL makeValid = defaults.automaticallyResolvesValidationErrors_cde;
    return [self newManagedObjectWithEntity:entity insertIntoManagedObjectContext:context makeInsertedObjectValid_cde:makeValid];
}

@end
