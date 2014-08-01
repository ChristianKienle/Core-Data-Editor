#import "CDE.h"

@class NSManagedObjectContext;
@class NSManagedObjectModel;

@interface CDE ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

#pragma mark - Presenting Errors
- (void)presentError:(NSError *)error;

@end
