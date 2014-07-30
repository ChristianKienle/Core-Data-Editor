#import <Foundation/Foundation.h>

@interface CDEModelChooserItem : NSObject

#pragma mark Creating
- (id)initWithTitleForDisplay:(NSString *)initTitleForDisplay URL:(NSURL *)initURL managedObjectModel:(NSManagedObjectModel *)initManagedObjectModel;

#pragma mark Properties
@property (nonatomic, readonly, copy) NSString *titleForDisplay;
@property (nonatomic, readonly, copy) NSURL *URL;
@property (nonatomic, readonly, retain) NSManagedObjectModel *managedObjectModel;

@end
