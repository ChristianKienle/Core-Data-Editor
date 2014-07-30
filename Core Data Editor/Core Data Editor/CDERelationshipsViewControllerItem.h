#import <Foundation/Foundation.h>

@interface CDERelationshipsViewControllerItem : NSObject

#pragma mark - Creating
- (instancetype)initWithRelationship:(NSRelationshipDescription *)relationship managedObject:(NSManagedObject *)managedObject;

#pragma mark - Properties
@property (nonatomic, strong, readwrite) NSRelationshipDescription *relationshipDescription;
@property (nonatomic, strong) NSManagedObject *managedObject;
@property (nonatomic, readonly) NSImage *imageRepresentingRelationshipType;
@property (nonatomic, readonly) NSUInteger numberOfRelatedObjects;

@end