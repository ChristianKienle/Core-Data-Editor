#import "NSManagedObjectModel-CDEAdditions.h"
#import "NSError-CDEAdditions.h"

@interface CDEBinaryDataValueTransformer : NSValueTransformer

#pragma mark - Getting the Name
+ (NSString *)valueTransformerName;

@end

@implementation CDEBinaryDataValueTransformer

#pragma mark - Getting the Name
+ (NSString *)valueTransformerName {
    return @"CDEBinaryDataValueTransformer";
}

#pragma mark - NSObject
+ (void)initialize {
    if(self == [CDEBinaryDataValueTransformer class]) {
        [NSValueTransformer setValueTransformer:[CDEBinaryDataValueTransformer new] forName:@"CDEBinaryDataValueTransformer"];
    }
}

#pragma mark - NSValueTransformer
+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
    return [NSData dataWithData:value];
}

- (id)reverseTransformedValue:(id)value {
    return [NSData dataWithData:value];
}

@end

@implementation NSManagedObjectModel (CDEAdditions)

#pragma mark - Creating
+ (BOOL)canInitWithContentsOfURL:(NSURL *)URL error_cde:(NSError **)error {
    if(URL == nil) {
        NSLog(@"WARNING: Called '%@' with a nil URL.", NSStringFromSelector(_cmd));
        return NO;
    }
        
    @try {
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:URL];
        if(model != nil) {
            // More Analysis: Find relations with no inverse
            for(NSEntityDescription *entity in model) {
                for(NSRelationshipDescription *relation in [[entity relationshipsByName] allValues]) {
                    if(relation.inverseRelationship == nil) {
                        if(error != NULL) {
                            NSString *description = [NSString stringWithFormat:@"The model %@ cannot be handled", URL.lastPathComponent];
                            NSString *reason = [NSString stringWithFormat:@"Your model has at least one relationship (%@) without an inverse. This is not supported.", relation.name];
                            *error = [NSError newErrorWithCode:-1 localizedDescription:description localizedRecoverySuggestion_cde:reason];
                        }

                        return NO;
                    }
                }
            }
            return YES;
        }
    }
    @catch (NSException *exception) {
        if(error != NULL) {
            NSString *description = [NSString stringWithFormat:@"The model %@ cannot be handled", URL.lastPathComponent];
            NSString *reason = [NSString stringWithFormat:@"Opening the model raised an exception: %@", exception.name];
            *error = [NSError newErrorWithCode:-1 localizedDescription:description localizedRecoverySuggestion_cde:reason];
        }
        return NO;
    }
    
    return NO;
}

#pragma mark - Compiling
+ (BOOL)managedObjectModelCompilationPossible_cde {
    return NO;
}

+ (NSManagedObjectModel *)newManagedObjectModelByCompilingFileAtURL:(NSURL *)fileURL error_cde:(NSError **)error {
    NSParameterAssert(fileURL);
    NSParameterAssert(fileURL.isFileURL);
    
    NSURL *modelURL = fileURL;
    if([fileURL.pathExtension isEqualToString:@"xcdatamodeld"]) {
        NSURL *versionPropertyListURL = [fileURL URLByAppendingPathComponent:@".xccurrentversion" isDirectory:NO];
        NSFileManager *fileManager = [NSFileManager new];
        if([fileManager fileExistsAtPath:versionPropertyListURL.path] == NO) {
            if(error != NULL) {
                *error = [NSError newErrorWithCode:-1 localizedDescription:@"File is versioned model but it does not contain a file called .xccurrentversion." localizedRecoverySuggestion_cde:@"Current version could not be determined."];
            }
            return nil;
        }
        
        NSDictionary *versionDictionary = [NSDictionary dictionaryWithContentsOfURL:versionPropertyListURL];
        if(versionDictionary == nil) {
            if(error != NULL) {
                *error = [NSError newErrorWithCode:-1 localizedDescription:@"The version file (.xccurrentversion) does not seem to be a valid property list." localizedRecoverySuggestion_cde:@"Current version could not be determined."];
            }
            return nil;
        }
        
        NSString *currentModelName = versionDictionary[@"_XCCurrentVersionName"];
        if(currentModelName == nil) {
            if(error != NULL) {
                *error = [NSError newErrorWithCode:-1 localizedDescription:@"The version file (.xccurrentversion) does not contain a key called _XCCurrentVersionName." localizedRecoverySuggestion_cde:@"Current version could not be determined."];
            }
            return nil;
        }
        
        modelURL = [fileURL URLByAppendingPathComponent:currentModelName isDirectory:NO];
    }
    
    NSAssert([modelURL.pathExtension isEqualToString:@"xcdatamodel"], @"Path extension should be xcdatamodel");
    
    NSString *xcrunName = @"/usr/bin/xcrun momc";
    NSMutableString *momcOptions = [NSMutableString string];
    NSArray *defaultMomcOptions = @[@"MOMC_NO_WARNINGS", @"MOMC_NO_INVERSE_RELATIONSHIP_WARNINGS", @"MOMC_SUPPRESS_INVERSE_TRANSIENT_ERROR"];
                                         
    for(NSString *option in defaultMomcOptions) {
        [momcOptions appendFormat:@" -%@ ", option];
    }
    NSString *momcIncantation = nil;
    NSString *tempGeneratedMomFileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"mom"];
    NSString *tempGeneratedMomFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempGeneratedMomFileName];
    momcIncantation = [NSString stringWithFormat:@"%@ %@ \"%@\" \"%@\"",
                       xcrunName,
                       momcOptions,
                       modelURL.path,
                       tempGeneratedMomFilePath];
    system([momcIncantation UTF8String]);
    
    //NSURL *compiledModelURL = [NSURL fileURLWithPath:tempGeneratedMomFilePath];
    
    return nil;
}

#pragma mark - Transforming
- (NSManagedObjectModel *)transformedManagedObjectModel_cde {
    NSData *originalModelData = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSManagedObjectModel *transformedModel = [NSKeyedUnarchiver unarchiveObjectWithData:originalModelData];
    
    // Remove custom Value Transformers
    for(NSEntityDescription *entityDescription in transformedModel) {
        NSArray *attributes = [[entityDescription attributesByName] allValues];
        for(NSAttributeDescription *attributeDescription in attributes) {
            if(attributeDescription.attributeType != NSTransformableAttributeType) {
                continue;
            }
            NSString *transformerName = attributeDescription.valueTransformerName;
            if([[NSValueTransformer valueTransformerNames] containsObject:transformerName] == YES) {
                continue;
            }
            attributeDescription.valueTransformerName = [CDEBinaryDataValueTransformer valueTransformerName];
        }
    }
    
    NSMutableDictionary *localizationDictionary = [NSMutableDictionary dictionary];
    for(NSEntityDescription *entityDescription in transformedModel) {
        NSDictionary *propertiesByName = entityDescription.propertiesByName;
        [propertiesByName enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSPropertyDescription *propertyDescription, BOOL *stop) {
            NSString *name = propertyName;
            NSString *entityName = entityDescription.name;
            NSString *localizedEntryKey = [NSString stringWithFormat:@"//Property/%@/Entity/%@", name, entityName];
            NSString *localizedEntryValue = name;
            if(localizedEntryKey != nil) {
                localizationDictionary[localizedEntryKey] = localizedEntryValue;
            }
        }];
    }
    transformedModel.localizationDictionary = localizationDictionary;
    return transformedModel;
}

#pragma mark - Compatibility
- (BOOL)isCompatibleWithStoreAtURL:(NSURL *)URL error_cde:(NSError **)error {
    NSParameterAssert(URL);
    NSError *metadataError = nil;
    NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:nil URL:URL error:&metadataError];
    if(metadata == nil) {
        if(error != NULL) {
            *error = metadataError;
        }
        NSLog(@"Failed to determine metadata: %@", metadataError);
        return NO;
    }
    
    BOOL isCompatible = [self isConfiguration:nil compatibleWithStoreMetadata:metadata];
    if(isCompatible == NO) {
        if(error != NULL) {
            *error = [NSError newErrorWithCode:-1 localizedDescription:@"Store is incompatible with Model" localizedRecoverySuggestion_cde:@"Make sure that the store file was generated by using the correct version of your model."];
        }
    }
    return isCompatible;
}

@end
