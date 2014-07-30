#import "CDEManagedObjectsRequest.h"

@interface CDEManagedObjectsRequest ()

#pragma mark - Properties 
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;

#pragma mark - Properties for a Entity Request
@property (nonatomic, strong, readwrite) NSEntityDescription *entityDescription;

#pragma mark - Properties for a Relationship Request
@property (nonatomic, strong, readwrite) NSManagedObject *managedObject;
@property (nonatomic, strong, readwrite) NSRelationshipDescription *relationshipDescription;

#pragma mark - Properties for a Fetch Request Request
@property (nonatomic, strong, readwrite) NSFetchRequest *fetchRequest;

@end

@implementation CDEManagedObjectsRequest

#pragma mark - Creating
// This is the designated Initializer
// This initializer is private because it is rather complicated.
- (instancetype)initWithEntityDescription:(NSEntityDescription *)entityDescription
                     managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                            managedObject:(NSManagedObject *)managedObject
                  relationshipDescription:(NSRelationshipDescription *)relationshipDescription
                             fetchRequest:(NSFetchRequest *)fetchRequest {
    self = [super init];
    if(self) {
        self.entityDescription = entityDescription;
        self.managedObjectContext = managedObjectContext;
        
        self.managedObject = managedObject;
        self.relationshipDescription = relationshipDescription;
        
        self.fetchRequest = fetchRequest;
    }
    return self;
}

- (instancetype)initWithEntityDescription:(NSEntityDescription *)entityDescription managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSParameterAssert(entityDescription);
    NSParameterAssert(managedObjectContext);
    return [self initWithEntityDescription:entityDescription
                      managedObjectContext:managedObjectContext
                             managedObject:nil
                   relationshipDescription:nil
                              fetchRequest:nil];
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject relationshipDescription:(NSRelationshipDescription *)relationshipDescription {
    NSParameterAssert(managedObject);
    NSParameterAssert(relationshipDescription);
    return [self initWithEntityDescription:relationshipDescription.destinationEntity
                      managedObjectContext:managedObject.managedObjectContext
                             managedObject:managedObject
                   relationshipDescription:relationshipDescription
                              fetchRequest:nil];
}

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSParameterAssert(fetchRequest);
    NSParameterAssert(fetchRequest.resultType == NSManagedObjectResultType);
    NSParameterAssert(fetchRequest.entity || fetchRequest.entityName);
    NSParameterAssert(managedObjectContext);
    
    // Determine the Entity
    NSEntityDescription *entity = fetchRequest.entity;
    if(entity == nil) {
        NSString *entityName = fetchRequest.entityName;
        NSManagedObjectModel *model = managedObjectContext.persistentStoreCoordinator.managedObjectModel;
        entity = model.entitiesByName[entityName];
        NSAssert(entity, @"Entity cannot be nil");
    }
    return [self initWithEntityDescription:entity
                      managedObjectContext:managedObjectContext
                             managedObject:nil
                   relationshipDescription:nil
                              fetchRequest:fetchRequest];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"CDEInvalidInitializer" reason:nil userInfo:nil];
}

#pragma mark - Properties
- (BOOL)isRelationshipRequest {
    return ([self managedObject] != nil && [self relationshipDescription] != nil && self.fetchRequest == nil);
}

- (BOOL)isEntityRequest {
    return ([self entityDescription] != nil && self.relationshipDescription == nil && self.fetchRequest == nil);
}

- (BOOL)isFetchRequest {
    return ([self entityDescription] != nil && self.relationshipDescription == nil && self.fetchRequest != nil);
}

- (NSManagedObject *)relatedObject {
    NSAssert(self.isRelationshipRequest && [self.relationshipDescription isToMany] == NO, @"Invalid kind of Request");
    return [self.managedObject valueForKey:self.relationshipDescription.name];
}

- (id)relatedObjects {
    NSAssert(self.isRelationshipRequest && [self.relationshipDescription isToMany], @"Invalid kind of Request");
    if(self.relationshipDescription.isOrdered) {
        return [self.managedObject mutableOrderedSetValueForKey:self.relationshipDescription.name];
    }
    
    return [self.managedObject mutableSetValueForKey:self.relationshipDescription.name];
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> -[%@ %@]", NSStringFromClass([self class]), self, self.managedObject.entity.name, self.relationshipDescription.name];
}

@end
