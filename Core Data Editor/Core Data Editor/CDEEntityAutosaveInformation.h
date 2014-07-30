#import <Foundation/Foundation.h>

@interface CDEEntityAutosaveInformation : NSObject

#pragma mark - Creating
- (instancetype)initWithEntityName:(NSString *)entityName items:(NSArray *)items;
+ (instancetype)newWithEntityName:(NSString *)entityName items:(NSArray *)items;

#pragma mark - Properties
@property (nonatomic, copy, readonly) NSString *entityName;
@property (nonatomic, copy, readonly) NSArray *items; // contains CDEEntityAutosaveInformationItems
@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;

#pragma mark - Equality
- (BOOL)isEqualToEntityAutosaveInformation:(CDEEntityAutosaveInformation *)entityAutosaveInformation;

@end