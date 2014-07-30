#import <Foundation/Foundation.h>

#import "CDEApplicationType.h"
extern 
@interface NSDictionary (CDEInfoDictionaryAdditions)

#pragma mark - Determine the application type of an Info Dictionary
- (CDEApplicationType)applicationType_cde;

@end
