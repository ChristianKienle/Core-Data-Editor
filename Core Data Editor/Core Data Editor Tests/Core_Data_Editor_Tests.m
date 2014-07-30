#import "Core_Data_Editor_Tests.h"
#import "NSManagedObjectModel-CDEAdditions.h"

@implementation Core_Data_Editor_Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}


- (NSURL *)_URLForModelNamed:(NSString *)modelName {
    NSAssert(modelName, @"Model Name cannot be nil.");
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:modelName withExtension:@"momd"];
    NSAssert(URL != nil, @"URL should not be nil");
    return URL;
}

- (void)testCanInit {
    XCTAssertTrue([NSManagedObjectModel canInitWithContentsOfURL:[self _URLForModelNamed:@"simple"] error_cde:NULL], @"Fail");
    XCTAssertFalse([NSManagedObjectModel canInitWithContentsOfURL:[self _URLForModelNamed:@"simple_no_inverse"] error_cde:NULL], @"Fail");
}

@end
