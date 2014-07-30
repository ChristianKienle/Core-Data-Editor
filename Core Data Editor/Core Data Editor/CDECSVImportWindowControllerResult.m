#import "CDECSVImportWindowControllerResult.h"

@interface CDECSVImportWindowControllerResult ()

#pragma mark Properties
@property (nonatomic, copy, readwrite) NSArray *items;
@property (nonatomic, strong, readwrite) NSEntityDescription *destinationEntityDescription;

@end

@implementation CDECSVImportWindowControllerResult

#pragma mark Creating
- (id)initWithItems:(NSArray *)items destinationEntityDescription:(NSEntityDescription *)destinationEntityDescription {
    self = [super init];
    if(self) {
        self.items = items;
        self.destinationEntityDescription = destinationEntityDescription;
    }
    return self;
}

- (id)init {
    return [self initWithItems:@[] destinationEntityDescription:nil];
}

@end
