#import <Foundation/Foundation.h>
#import "CDEApplicationType.h"

@interface NSBundle (CDEApplicationAnalyzer)

#pragma mark - Properties
@property (nonatomic, readonly, getter = isApplicationBundle_cde) BOOL isApplicationBundle_cde;
@property (nonatomic, readonly) CDEApplicationType applicationType_cde;

#pragma mark - Extracting the Model
- (NSManagedObjectModel *)transformedManagedObjectModelAndGetError:(NSError **)error;

@end
