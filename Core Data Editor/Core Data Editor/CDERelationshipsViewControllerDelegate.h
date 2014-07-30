#import <Foundation/Foundation.h>

@class CDERelationshipsViewController;

@protocol CDERelationshipsViewControllerDelegate <NSObject>

- (void)relationshipsViewController:(CDERelationshipsViewController *)relationshipsViewController didSelectRelationshipDescription:(NSRelationshipDescription *)relationshipDescription;

@end
