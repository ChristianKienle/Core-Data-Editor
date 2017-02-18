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
    entityDescription.managedObjectClassName = NSStringFromClass([NSManagedObject class]);
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
  
  NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:URL options:nil error:&metadataError];
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
