#import <CoreData/CoreData.h>

#pragma mark - Working with Attribute Types
extern BOOL CDEIsStringAttributeType(NSAttributeType type);
extern BOOL CDEIsFloatingPointAttributeType(NSAttributeType type);
extern BOOL CDEIsIntegerAttributeType(NSAttributeType type);

@interface NSAttributeDescription (CDEAdditions)


#pragma mark - Getting Cell Classes
// Returns the class for the attribute type
- (Class)tableCellViewClass_cde;
+ (Class)tableCellViewClassForAttributeType_cde:(NSAttributeType)type;

#pragma mark - Concenience
@property (nonatomic, readonly, getter = isSupportedAttribute_cde) BOOL isSupportedAttribute;
@property (nonatomic, readonly, getter = isAttributeWithFloatingPointCharacteristics_cde) BOOL isAttributeWithFloatingPointCharacteristics_cde;

@property (nonatomic, readonly, getter = isAttributeWithIntegerCharacteristics_cde) BOOL isAttributeWithIntegerCharacteristics_cde;
+ (BOOL)attributeTypeHasIntegerCharacteristics_cde:(NSAttributeType)type;

@property (nonatomic, readonly, copy, getter = sortDescriptorPrototype_cde) NSSortDescriptor *sortDescriptorPrototype_cde;
+ (NSPredicateOperatorType)predicateOperatorTypeForAttributeType_cde:(NSAttributeType)type;

#pragma mark - CSV
@property (nonatomic, readonly, getter = isSupportedCSVAttribute_cde) BOOL isSupportedCSVAttribute_cde;
+ (BOOL)isSupportedCSVAttributeType_cde:(NSAttributeType)type;

@end
