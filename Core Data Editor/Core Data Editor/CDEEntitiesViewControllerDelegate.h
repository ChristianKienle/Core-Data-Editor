#import <Foundation/Foundation.h>

@class CDEEntitiesViewController;

@protocol CDEEntitiesViewControllerDelegate <NSObject>

@required
- (void)entitiesViewController:(CDEEntitiesViewController *)entitiesViewController didSelectEntityDescription:(NSEntityDescription *)entityDescription;

@end
