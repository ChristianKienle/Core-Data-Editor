#import <Cocoa/Cocoa.h>

@interface CDEManagedObjectsTableViewAttributeHelper : NSObject

+ (NSFormatter *)formatterForAttributeType:(NSAttributeType)attributeType;
+ (BOOL)attributeTypeIsDisplayable:(NSAttributeType)attributeType;
+ (NSTableColumn *)tableColumnWithAttributeDescription:(NSAttributeDescription *)attributeDescription arrayController:(NSArrayController *)arrayController;
+ (BOOL)attributeTypeIsNumber:(NSAttributeType)attributeType;
+ (id)transformedValueFromString:(NSString *)inputString attributeType:(NSAttributeType)attributeType;
+ (NSPredicateOperatorType)predicateOperatorTypeForAttributeType:(NSAttributeType)attributeType;

@end
