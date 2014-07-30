#import <Foundation/Foundation.h>

@class CDEEntityAutosaveInformation;

// This class is mutable by design
@interface CDEAutosaveInformation : NSObject

#pragma mark - Creating
- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation;

#pragma mark - Working with the Information
- (CDEEntityAutosaveInformation *)informationForEntityNamed:(NSString *)name; // may return nil
- (void)setInformation:(CDEEntityAutosaveInformation *)information forEntityNamed:(NSString *)name; // if information = nil then information will be removed

#pragma mark - Properties
@property (nonatomic, readonly) id representationForSerialization;

#pragma mark - Equality
- (BOOL)isEqualToAutosaveInformation:(CDEAutosaveInformation *)autosaveInformation;

@end
