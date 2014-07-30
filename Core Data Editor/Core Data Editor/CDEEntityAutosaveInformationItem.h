#import <Foundation/Foundation.h>

@interface CDEEntityAutosaveInformationItem : NSObject

#pragma mark - Creating
+ (instancetype)newWithProperties:(NSDictionary *)properties;
+ (instancetype)newWithIdentifier:(NSString *)identifier width:(CGFloat)width;
- (instancetype)initWithIdentifier:(NSString *)identifier width:(CGFloat)width;

#pragma mark - Properties
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, assign, readonly) CGFloat width;
@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;

#pragma mark - Equality
- (BOOL)isEqualToItem:(CDEEntityAutosaveInformationItem *)item;

@end