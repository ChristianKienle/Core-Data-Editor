#import "CDEEntityAutosaveInformationItem.h"

@interface CDEEntityAutosaveInformationItem ()

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, assign, readwrite) CGFloat width;

@end

@implementation CDEEntityAutosaveInformationItem

#pragma mark - Creating
+ (instancetype)newWithProperties:(NSDictionary *)properties {
    NSString *identifier = properties[@"identifier"];
    NSNumber *width = properties[@"width"];
    CGFloat widthValue = (width != nil ? width.doubleValue : 100.0);
    return [self newWithIdentifier:identifier width:widthValue];
}

+ (instancetype)newWithIdentifier:(NSString *)identifier width:(CGFloat)width {
    return [[self alloc] initWithIdentifier:identifier width:width];
}

- (instancetype)initWithIdentifier:(NSString *)identifier width:(CGFloat)width {
    NSParameterAssert(identifier);
    
    self = [super init];
    if(self) {
        self.identifier = identifier;
        self.width = width;
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"CDEInvalidInitializer" reason:nil userInfo:nil];
}

#pragma mark - Properties
- (NSDictionary *)dictionaryRepresentation {
    return @{ @"identifier" : self.identifier,
              @"width" : @(self.width) };
}

#pragma mark - Equality
- (BOOL)isEqualToItem:(CDEEntityAutosaveInformationItem *)item {
    if(item == nil) {
        return NO;
    }
    
    if(item == self) {
        return YES;
    }
    
    BOOL widthEqual = (fabs((self.width) - (item.width)) < DBL_EPSILON);
    if(widthEqual == NO) {
        return NO;
    }
    
    return [self.identifier isEqualToString:item.identifier];
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ = %f", [super description], self.identifier, self.width];
}

@end
