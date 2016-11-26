#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface NSError (CDEValidation)

#pragma mark - Properties
@property (readonly) BOOL isSupportedValidationError_cde;
@property (nullable, readonly) NSAttributeDescription *invalidAttribute_cde;
@property (nullable, readonly) NSManagedObject *invalidManagedObject_cde;
@property (nullable, readonly) NSEntityDescription *entityDescription_cde;
@property (nullable, readonly) NSArray<NSError*> *detailedErrors_cde;
@property (readonly) BOOL containsDetailedErrors_cde;

@end
