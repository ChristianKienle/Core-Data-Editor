#import "CDECSVDelimiter.h"

typedef enum {
    CDECSVDelimiterMenuItemTagComma = 0,
    CDECSVDelimiterMenuItemTagSemicolon = 1,
    CDECSVDelimiterMenuItemTagTabulator = 2
} CDECSVDelimiterMenuItemTag;

@interface CDECSVDelimiter ()

#pragma mark Getting Delimiter Instances
+ (NSDictionary *)delimiterStringValueForMenuItemTagMapping;

#pragma mark Creating
- (id)initWithStringRepresentation:(NSString *)stringRepresentation_ menuItemTag:(NSInteger)menuItemTag_;

#pragma mark Properties
@property (nonatomic, copy, readwrite) NSString *stringRepresentation;
@property (nonatomic, assign, readwrite) NSInteger menuItemTag;

@end

@implementation CDECSVDelimiter

#pragma mark Getting Delimiter Instances
+ (NSDictionary *)delimiterStringValueForMenuItemTagMapping {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@(CDECSVDelimiterMenuItemTagComma)] = @",";
    result[@(CDECSVDelimiterMenuItemTagSemicolon)] = @";";
    result[@(CDECSVDelimiterMenuItemTagTabulator)] = @"\t";
    return result;
}

+ (CDECSVDelimiter *)delimiterForMenuItemTag:(NSInteger)menuItemTag {
    NSString *stringValue = [self delimiterStringValueForMenuItemTagMapping][@(menuItemTag)];
    if(stringValue == nil) {
        return nil;
    }
    return [[CDECSVDelimiter alloc] initWithStringRepresentation:stringValue menuItemTag:menuItemTag];
}

#pragma mark Creating
- (id)initWithStringRepresentation:(NSString *)stringRepresentation_ menuItemTag:(NSInteger)menuItemTag_ {
    self = [super init];
    if(self) {
        self.stringRepresentation = stringRepresentation_;
        self.menuItemTag = menuItemTag_;
    }
    return self;
}

- (id)init {
    return [self initWithStringRepresentation:@"," menuItemTag:CDECSVDelimiterMenuItemTagComma];
}



@end
