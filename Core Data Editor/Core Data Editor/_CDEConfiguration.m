// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDEConfiguration.m instead.

#import "_CDEConfiguration.h"

const struct CDEConfigurationAttributes CDEConfigurationAttributes = {
	.applicationBundleBookmarkData = @"applicationBundleBookmarkData",
	.autosaveInformationByEntityName = @"autosaveInformationByEntityName",
	.isMacApplication = @"isMacApplication",
	.modelBookmarkData = @"modelBookmarkData",
	.storeBookmarkData = @"storeBookmarkData",
};

const struct CDEConfigurationRelationships CDEConfigurationRelationships = {
};

const struct CDEConfigurationFetchedProperties CDEConfigurationFetchedProperties = {
};

@implementation CDEConfigurationID
@end

@implementation _CDEConfiguration

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDEConfiguration" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDEConfiguration";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDEConfiguration" inManagedObjectContext:moc_];
}

- (CDEConfigurationID*)objectID {
	return (CDEConfigurationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isMacApplicationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isMacApplication"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic applicationBundleBookmarkData;






@dynamic autosaveInformationByEntityName;






@dynamic isMacApplication;



- (BOOL)isMacApplicationValue {
	NSNumber *result = [self isMacApplication];
	return [result boolValue];
}

- (void)setIsMacApplicationValue:(BOOL)value_ {
	[self setIsMacApplication:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsMacApplicationValue {
	NSNumber *result = [self primitiveIsMacApplication];
	return [result boolValue];
}

- (void)setPrimitiveIsMacApplicationValue:(BOOL)value_ {
	[self setPrimitiveIsMacApplication:[NSNumber numberWithBool:value_]];
}





@dynamic modelBookmarkData;






@dynamic storeBookmarkData;











@end
