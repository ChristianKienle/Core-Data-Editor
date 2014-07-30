#import <Cocoa/Cocoa.h>

@class CDECSVImportWindowControllerResult;

typedef void(^CDECSVImportWindowControllerCompletionHandler)(CDECSVImportWindowControllerResult *result);

@interface CDECSVImportWindowController : NSWindowController

#pragma mark - Properties
@property (nonatomic, copy, readonly) NSArray *entityDescriptions;

#pragma mark Presenting the Window Controller
- (void)beginSheetModalForWindow:(NSWindow *)window entityDescriptions:(NSArray *)entityDescriptions selectedEntityDescription:(NSEntityDescription *)selectedEntityDescription completionHandler:(CDECSVImportWindowControllerCompletionHandler)completionHandler;

@end
