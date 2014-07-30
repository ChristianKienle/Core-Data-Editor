#import <Foundation/Foundation.h>

@interface CDEManagedObjectsRequest : NSObject

#pragma mark - Creating
- (instancetype)initWithEntityDescription:(NSEntityDescription *)entityDescription managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject relationshipDescription:(NSRelationshipDescription *)relationshipDescription;
- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

#pragma mark - Properties for a Entity Request
@property (nonatomic, strong, readonly) NSEntityDescription *entityDescription;

#pragma mark - Properties for a Relationship Request
@property (nonatomic, strong, readonly) NSManagedObject *managedObject;
@property (nonatomic, strong, readonly) NSRelationshipDescription *relationshipDescription;
@property (nonatomic, strong, readonly) NSManagedObject *relatedObject; // only for To-One
@property (nonatomic, strong, readonly) id relatedObjects; // only for To-Many - returns a mutable proxy (for both ordered and unordered)

#pragma mark - Properties for a Fetch Request Request
@property (nonatomic, strong, readonly) NSFetchRequest *fetchRequest;

#pragma mark - Properties
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) BOOL isRelationshipRequest;
@property (nonatomic, readonly) BOOL isEntityRequest;
@property (nonatomic, readonly) BOOL isFetchRequest;

@end