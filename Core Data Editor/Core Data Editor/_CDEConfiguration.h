// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDEConfiguration.h instead.

#import <CoreData/CoreData.h>


extern const struct CDEConfigurationAttributes {
	__unsafe_unretained NSString *applicationBundleBookmarkData;
	__unsafe_unretained NSString *autosaveInformationByEntityName;
	__unsafe_unretained NSString *isMacApplication;
	__unsafe_unretained NSString *modelBookmarkData;
	__unsafe_unretained NSString *storeBookmarkData;
} CDEConfigurationAttributes;

extern const struct CDEConfigurationRelationships {
} CDEConfigurationRelationships;

extern const struct CDEConfigurationFetchedProperties {
} CDEConfigurationFetchedProperties;



@class NSDictionary;




@interface CDEConfigurationID : NSManagedObjectID {}
@end

@interface _CDEConfiguration : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDEConfigurationID*)objectID;





@property (nonatomic, strong) NSData* applicationBundleBookmarkData;



//- (BOOL)validateApplicationBundleBookmarkData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDictionary* autosaveInformationByEntityName;



//- (BOOL)validateAutosaveInformationByEntityName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isMacApplication;



@property BOOL isMacApplicationValue;
- (BOOL)isMacApplicationValue;
- (void)setIsMacApplicationValue:(BOOL)value_;

//- (BOOL)validateIsMacApplication:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* modelBookmarkData;



//- (BOOL)validateModelBookmarkData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* storeBookmarkData;



//- (BOOL)validateStoreBookmarkData:(id*)value_ error:(NSError**)error_;






@end

@interface _CDEConfiguration (CoreDataGeneratedAccessors)

@end

@interface _CDEConfiguration (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveApplicationBundleBookmarkData;
- (void)setPrimitiveApplicationBundleBookmarkData:(NSData*)value;




- (NSDictionary*)primitiveAutosaveInformationByEntityName;
- (void)setPrimitiveAutosaveInformationByEntityName:(NSDictionary*)value;




- (NSNumber*)primitiveIsMacApplication;
- (void)setPrimitiveIsMacApplication:(NSNumber*)value;

- (BOOL)primitiveIsMacApplicationValue;
- (void)setPrimitiveIsMacApplicationValue:(BOOL)value_;




- (NSData*)primitiveModelBookmarkData;
- (void)setPrimitiveModelBookmarkData:(NSData*)value;




- (NSData*)primitiveStoreBookmarkData;
- (void)setPrimitiveStoreBookmarkData:(NSData*)value;




@end
