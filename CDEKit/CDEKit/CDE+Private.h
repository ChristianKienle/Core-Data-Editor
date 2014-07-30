#import "CDE.h"

@class NSManagedObjectContext;
@class NSManagedObjectModel;

@interface CDE ()

+ (CDE *)sharedCoreDataEditor;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

#pragma mark - Presenting Errors
- (void)presentError:(NSError *)error;

@end
