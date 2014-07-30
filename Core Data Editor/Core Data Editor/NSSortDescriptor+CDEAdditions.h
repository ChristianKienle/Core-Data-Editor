#import <Cocoa/Cocoa.h>

@interface NSSortDescriptor (CDEAdditions)

#pragma mark - Getting Sort Descriptors
+ (instancetype)newSortDescriptorForObjectIDColumn_cde;

@end
