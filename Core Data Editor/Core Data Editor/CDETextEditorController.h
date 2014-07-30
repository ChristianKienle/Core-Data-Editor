#import <Foundation/Foundation.h>

typedef void(^CDETextEditorControllerCompletionHandler)(NSString *editedStringValue);

@interface CDETextEditorController : NSObject

#pragma mark - Showing the Editor
- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge stringValue:(NSString *)stringValue completionHandler:(CDETextEditorControllerCompletionHandler)completionHandler;


@end
