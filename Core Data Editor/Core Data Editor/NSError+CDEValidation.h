#import <Foundation/Foundation.h>

@interface NSError (CDEValidation)

#pragma mark - Properties
@property (nonatomic, readonly) BOOL isSupportedValidationError_cde;
@property (nonatomic, readonly) NSAttributeDescription *invalidAttribute_cde;
@property (nonatomic, readonly) NSManagedObject *invalidManagedObject_cde;
@property (nonatomic, readonly) NSEntityDescription *entityDescription_cde;
@property (nonatomic, readonly) NSArray *detailedErrors_cde;
@property (nonatomic, readonly) BOOL containsDetailedErrors_cde;

@end
