#import <Cocoa/Cocoa.h>

@interface CDEBinaryDataToSizeValueTransformer : NSValueTransformer

#pragma mark - Convenience
+ (void)registerDefaultCoreDataEditorBinaryDataToSizeValueTransformer;

#pragma mark Metadata
+ (NSString *)name;

@end
