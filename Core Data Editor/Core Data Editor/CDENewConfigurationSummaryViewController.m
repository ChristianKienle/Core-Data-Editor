#import "CDENewConfigurationSummaryViewController.h"
#import "CDEConfigurationSummaryRequest.h"

#import "CDESupportedStoreType.h"
#import "CDEApplicationType.h"

// Additions: Begin
#import "NSPersistentStore+CDEStoreAnalyzer.h"
#import "NSBundle+CDEApplicationAnalyzer.h"
#import "NSString+CDEPersistentStore.h"
// Additions: End

@interface NSString (CDEStoreTypePopupButtonAdditions)

#pragma mark - Properties
@property (nonatomic, readonly) NSInteger indexOfItem_cde;

@end

@implementation NSString (CDEStoreTypePopupButtonAdditions)

#pragma mark - Properties
- (NSInteger)indexOfItem_cde {
    CDESupportedStoreType supportedStoreType = [self supportedStoreType_cde];
    switch (supportedStoreType) {
        case CDESupportedStoreTypeSQLite: {
            return 0;
        }
        case CDESupportedStoreTypeXML: {
            return 1;
        }
        case CDESupportedStoreTypeBinary: {
            return 2;
        }
        case CDESupportedStoreTypeUnknown: {
            @throw [NSException exceptionWithName:@"CDEInvalidStoreType" reason:nil userInfo:nil];
        }
        default: {
            @throw [NSException exceptionWithName:@"CDEInvalidStoreType" reason:nil userInfo:nil];
        }
    }
    return 0;
}

@end

@interface CDENewConfigurationSummaryViewController ()

#pragma mark Outlets
@property (nonatomic, weak) IBOutlet NSPopUpButton *applicationTypePopUpButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *storeTypePopUpButton;

#pragma mark Properties
@property (nonatomic, readonly) CDEConfigurationSummaryRequest *request;

@end

@implementation CDENewConfigurationSummaryViewController

#pragma mark Properties
- (CDEConfigurationSummaryRequest *)request {
    return (CDEConfigurationSummaryRequest *)self.representedObject;
}

#pragma mark Creating
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
    }
    return self;
}

- (id)init {
    return [self initWithNibName:NSStringFromClass([self class])  bundle:nil];
}

#pragma mark NSViewController
- (void)setRepresentedObject:(id)newRepresentedObject {
    if(newRepresentedObject != nil) {
        NSAssert([newRepresentedObject isKindOfClass:[CDEConfigurationSummaryRequest class]], @"Invalid class");
    }
    
    [super setRepresentedObject:newRepresentedObject];
    
    if(self.request == nil) {
        return;
    }
    
    NSBundle *applicationBundle = [NSBundle bundleWithURL:self.request.applicationBundleURL];
    
    NSInteger indexForApplicationType = 0;
    
    CDEApplicationType applicationType = [applicationBundle applicationType_cde];
    switch (applicationType) {
        case CDEApplicationTypeOSX: {
            indexForApplicationType = 0;
            break;
        }
        case CDEApplicationTypeiOS: {
            indexForApplicationType = 1;
            break;
        }
        case CDEApplicationTypeUnknown: {
            indexForApplicationType = 0; // Default
            break;
        }
        default: {
            @throw [NSException exceptionWithName:@"CDEInvalidApplicationType" reason:nil userInfo:nil];
        }
            
    }
    
    [self.applicationTypePopUpButton selectItemAtIndex:indexForApplicationType];
    
    NSString *storeType = [NSPersistentStore typeOfPersistentStoreAtURL_cde:self.request.storeURL];
    
    [self.storeTypePopUpButton selectItemAtIndex:[storeType indexOfItem_cde]];
}

@end
