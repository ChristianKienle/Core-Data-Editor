#import <Foundation/Foundation.h>

@interface CDEMenuItem : NSObject

#pragma mark Creating
- (id)initWithTitle:(NSString *)initTitle target:(id)initTarget action:(SEL)initAction representedObject:(id)initRepresentedObject badgeValue:(NSString *)initBadgeValue showsBadge:(BOOL)initShowsBadge;

#pragma mark Properties
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, assign) SEL action;
@property (nonatomic, readonly, assign) id target;
@property (nonatomic, readonly, retain) id representedObject;
@property (nonatomic, readonly, copy) NSString *badgeValue;
@property (nonatomic, readonly, assign) BOOL showsBadge;

@end