#import <Cocoa/Cocoa.h>

@interface CDEAttributeEditorViewController : NSViewController

#pragma mark - Creating 
- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
                 attributeDescription:(NSAttributeDescription *)attributeDescription;

@end
