#import <Foundation/Foundation.h>

typedef void(^CDECodeGeneratorCompletionHandler)(void);

@interface CDECodeGenerator : NSObject

#pragma mark Creating
- (instancetype)initWithManagedObjectModelURL:(NSURL *)managedObjectModelURL_;

#pragma mark Properties
@property (nonatomic, strong, readonly) NSURL *managedObjectModelURL;

#pragma mark Presenting the Code Generator UI
- (void)presentCodeGeneratorUIModalForWindow:(NSWindow *)parentWindow_ completionHandler:(CDECodeGeneratorCompletionHandler)completionHandler_;

@end
