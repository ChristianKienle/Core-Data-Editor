#import <Cocoa/Cocoa.h>

@class CDEMenuItem;
@interface CDEMenuWindowItem : NSViewController

#pragma mark Properties
@property (nonatomic, retain) CDEMenuItem *item;

@end
