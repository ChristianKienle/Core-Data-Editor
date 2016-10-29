#import "CDEManagedObjectsTableViewAttributeHelper.h"
#import "CDEBinaryDataToSizeValueTransformer.h"

@implementation CDEManagedObjectsTableViewAttributeHelper

+ (NSFormatter *)formatterForAttributeType:(NSAttributeType)attributeType {
    if(attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType || attributeType == NSDecimalAttributeType || attributeType == NSDoubleAttributeType || attributeType == NSFloatAttributeType || attributeType == NSBooleanAttributeType) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
       BOOL allowsFloats = (attributeType == NSDoubleAttributeType || attributeType == NSFloatAttributeType || attributeType == NSDecimalAttributeType);
       [formatter setAllowsFloats:allowsFloats];
       if(allowsFloats) {
          [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
       }

       return formatter;
    }
    
    if(attributeType == NSStringAttributeType || attributeType == NSBinaryDataAttributeType || attributeType == NSUndefinedAttributeType || attributeType == NSTransformableAttributeType) {
        return nil;
    }
    
    if(attributeType == NSDateAttributeType) {
        NSDateFormatter *formatter = [NSDateFormatter new];
       [formatter setTimeStyle:NSDateFormatterLongStyle];
       [formatter setDateStyle:NSDateFormatterMediumStyle];
        return formatter;
    }
    return nil;
}

+ (BOOL)attributeTypeIsDisplayable:(NSAttributeType)attributeType {
    return (attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType || attributeType == NSDecimalAttributeType || attributeType == NSDoubleAttributeType || attributeType == NSFloatAttributeType || attributeType == NSBooleanAttributeType || attributeType == NSStringAttributeType || attributeType == NSBooleanAttributeType || attributeType == NSDateAttributeType || attributeType == NSBinaryDataAttributeType || attributeType == NSTransformableAttributeType);
}

+ (NSTableColumn *)tableColumnWithAttributeDescription:(NSAttributeDescription *)attributeDescription arrayController:(NSArrayController *)arrayController {
    NSTableColumn *result = [[NSTableColumn alloc] initWithIdentifier:[attributeDescription name]];
    [[result headerCell] setStringValue:[attributeDescription name]];
   //[result setMinWidth:150.0];
   [result sizeToFit];
   if([result width] < 100.0) {
      [result setWidth:100.0];
   }
   NSDictionary *bindingOptions = [NSMutableDictionary dictionary];
   
    if([attributeDescription attributeType] == NSBooleanAttributeType) {
        NSButtonCell *booleanDataCell = [[NSButtonCell alloc] initTextCell:[NSString string]];
        [booleanDataCell setButtonType:NSSwitchButton];
        [booleanDataCell setAlignment:NSTextAlignmentCenter];
        [booleanDataCell setImagePosition:NSImageOnly];
        [result setDataCell:booleanDataCell];
    }
        
    if([attributeDescription attributeType] == NSDateAttributeType) {
        NSTextFieldCell *dateDataCell = [[NSTextFieldCell alloc] initTextCell:[NSString string]];
        [dateDataCell setEditable:YES];       
        [result setDataCell:dateDataCell];
    }    
   
   if(attributeDescription.attributeType == NSBinaryDataAttributeType || attributeDescription.attributeType == NSTransformableAttributeType) {
      NSTextFieldCell *dateDataCell = [[NSTextFieldCell alloc] initTextCell:[NSString string]];
      [dateDataCell setEditable:NO];       
      [result setDataCell:dateDataCell];
      [bindingOptions setValue:[CDEBinaryDataToSizeValueTransformer name] forKey:NSValueTransformerNameBindingOption];
   }
   
    if([self formatterForAttributeType:[attributeDescription attributeType]] != nil) {
        [[result dataCell] setFormatter:[self formatterForAttributeType:[attributeDescription attributeType]]];
    }

    [result bind:NSValueBinding toObject:arrayController withKeyPath:[@"arrangedObjects." stringByAppendingString:[attributeDescription name]] options:bindingOptions];
    
   SEL sortSelector = @selector(compare:);
   if(attributeDescription.attributeType == NSStringAttributeType) {
      sortSelector = @selector(localizedStandardCompare:);
   }
    
    [result setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:[NSString stringWithFormat:@"%@", [attributeDescription name]] ascending:NO selector:sortSelector]];


    if(attributeDescription.attributeType == NSBinaryDataAttributeType || attributeDescription.attributeType == NSTransformableAttributeType) {
        NSSortDescriptor *sortBinary = [NSSortDescriptor sortDescriptorWithKey:attributeDescription.name ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
            if([obj1 length] > [obj2 length]) {
                return NSOrderedDescending;
            }
            if([obj1 length] < [obj2 length]) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;

        }];
        [result setSortDescriptorPrototype:sortBinary];
    }
   
    return result;
}

+ (BOOL)attributeTypeIsNumber:(NSAttributeType)attributeType {
    return (attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType || attributeType == NSDecimalAttributeType || attributeType == NSDoubleAttributeType || attributeType == NSFloatAttributeType);
}

+ (id)transformedValueFromString:(NSString *)inputString attributeType:(NSAttributeType)attributeType {
    if(attributeType == NSStringAttributeType) {
        return inputString;
    }
    if([self attributeTypeIsNumber:attributeType]) {
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        return [numberFormatter numberFromString:inputString];
    }
    return nil;
}

+ (NSPredicateOperatorType)predicateOperatorTypeForAttributeType:(NSAttributeType)attributeType {
    if(attributeType == NSStringAttributeType) {
        return NSContainsPredicateOperatorType;
    }
    if([self attributeTypeIsNumber:attributeType]) {
        return NSEqualToPredicateOperatorType;
    }
    return NSEqualToPredicateOperatorType;    
}

@end
