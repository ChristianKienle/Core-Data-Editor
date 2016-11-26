#import "NSManagedObject+CDEAdditions.h"
#import "NSError+CDEValidation.h"

@implementation NSManagedObject (CDEAdditions)

- (nonnull NSArray<NSError*> *)validationErrors_cde {
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
        return @[];
    }
    if(error == nil) {
      return @[];
    }
    if(error.containsDetailedErrors_cde == NO) {
        return @[error];
    }
    return error.detailedErrors_cde;
}

- (NSArray<NSAttributeDescription*>* _Nonnull)invalidAttributes {
  NSArray *errors = self.validationErrors_cde;
  if(errors == nil) {
    return @[];
  }
  NSMutableArray *result = [@[] mutableCopy];
  for(NSError *error in errors) {
    NSAttributeDescription *attribute = error.invalidAttribute_cde;
    if(attribute == nil) {
      continue;
    }
    [result addObject:attribute];
  }
  return result;
}

@end
