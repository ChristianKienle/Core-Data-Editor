#import <Foundation/Foundation.h>

typedef void(^CDEManagedObjectsPickerCompletionHandler)(/* NSSet or NSOrderedSet */id selectedObjects);

@interface CDEManagedObjectsPicker : NSObject

#pragma mark - Show the Picker
- (void)displayObjectsOfEntityDescription:(NSEntityDescription *)entityDescription
                   selectedManagedObjects:(id)selectedManagedObjects // can be a NSSet or NSOrderedSet
                     managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  allowsMultipleSelection:(BOOL)allowsMultipleSelection
                       showRelativeToRect:(NSRect)positioningRect
                                   ofView:(NSView *)positioningView
                        completionHandler:(CDEManagedObjectsPickerCompletionHandler)completionHandler;

@end
