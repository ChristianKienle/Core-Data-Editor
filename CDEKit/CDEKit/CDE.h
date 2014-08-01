#import <Foundation/Foundation.h>
#import <CDEKit/CDEEntitiesViewController.h>
#import <CDEKit/CDEManagedObjectsViewController.h>
#import <CDEKit/CDEManagedObjectViewController.h>

@interface CDE : NSObject

+ (instancetype)sharedCoreDataEditor;

#pragma mark - Creating a Embedded Core Data Editor
- (void)enableEmbeddedCoreDataEditorWithMainContext:(NSManagedObjectContext *)mainContext;

@end
