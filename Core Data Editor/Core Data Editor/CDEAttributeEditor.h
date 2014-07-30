#import <Foundation/Foundation.h>
typedef void(^CDEAttributeEditorCompletionHandler)(void);

@interface CDEAttributeEditor : NSObject

#pragma mark - Showing the Editor
- (void)showEditorForManagedObject:(NSManagedObject *)managedObject
              attributeDescription:(NSAttributeDescription *)attributeDescription
                showRelativeToRect:(NSRect)positioningRect
                            ofView:(NSView *)positioningView
                 completionHandler:(CDEAttributeEditorCompletionHandler)completionHandler;

#pragma mark - Closing the Editor
@property (nonatomic, readonly, getter=isShown) BOOL shown;
- (void)close;

@end
