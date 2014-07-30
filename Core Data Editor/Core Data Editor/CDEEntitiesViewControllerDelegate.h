#import <Foundation/Foundation.h>

@class CDEEntitiesViewController;

@protocol CDEEntitiesViewControllerDelegate <NSObject>

@required
- (void)entitiesViewController:(CDEEntitiesViewController *)entitiesViewController didSelectEntitiyDescription:(NSEntityDescription *)entityDescription;

@end
