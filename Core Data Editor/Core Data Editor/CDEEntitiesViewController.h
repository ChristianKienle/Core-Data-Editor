#import <Cocoa/Cocoa.h>

@protocol CDEEntitiesViewControllerDelegate;

@interface CDEEntitiesViewController : NSViewController

#pragma mark - Properties
@property (nonatomic, weak) id<CDEEntitiesViewControllerDelegate> delegate;
@property (nonatomic, readonly) NSEntityDescription *selectedEntityDescription;

#pragma mark - Displaying Data
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

#pragma mark - UI
- (void)updateUIOfVisibleEntities;


@end
