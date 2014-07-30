#import <Cocoa/Cocoa.h>

@interface CDEAttributeEditorWindowController : NSWindowController

#pragma mark - Creating
- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
                 attributeDescription:(NSAttributeDescription *)attributeDescription;

@end
