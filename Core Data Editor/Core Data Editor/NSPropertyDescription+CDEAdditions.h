#import <CoreData/CoreData.h>

@interface NSPropertyDescription (CDEAdditions)

#pragma mark - Convenience
- (BOOL)isAttributeDescription_cde;
- (BOOL)isRelationshipDescription_cde;
@property (nonatomic, readonly) NSString *nameForDisplay_cde;

@end
