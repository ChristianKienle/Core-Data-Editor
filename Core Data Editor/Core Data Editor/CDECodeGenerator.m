#import "CDECodeGenerator.h"
#import "CDEManagedObjectSubclassesGenerator.h"
#import "CDECodeGeneratorAccessoryViewController.h"

@interface CDECodeGenerator ()

#pragma mark Properties
@property (nonatomic, strong, readwrite) NSURL *managedObjectModelURL;
@property (nonatomic, copy) CDECodeGeneratorCompletionHandler completionHandler;
@property (nonatomic, strong) CDECodeGeneratorAccessoryViewController *accessoryViewController;

@end

@implementation CDECodeGenerator

#pragma mark Creating
- (instancetype)initWithManagedObjectModelURL:(NSURL *)managedObjectModelURL {
    self = [super init];
    if(self) {
        self.completionHandler = nil;
        self.managedObjectModelURL = managedObjectModelURL;
        self.accessoryViewController = [CDECodeGeneratorAccessoryViewController new];
    }
    return self;
}

- (instancetype)init {
    return [self initWithManagedObjectModelURL:nil];
}

#pragma mark Presenting the Code Generator UI
- (void)presentCodeGeneratorUIModalForWindow:(NSWindow *)parentWindow completionHandler:(CDECodeGeneratorCompletionHandler)completionHandler {
    if(parentWindow == nil) {
        self.completionHandler = nil;
        return;
    }
    self.completionHandler = completionHandler;
    NSOpenPanel *savePanel = [NSOpenPanel openPanel];
    [savePanel setCanChooseDirectories:YES];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setCanChooseFiles:NO];
    [savePanel setPrompt:@"Generate"];
    savePanel.accessoryView = self.accessoryViewController.view;
    [savePanel beginSheetModalForWindow:parentWindow completionHandler:^(NSInteger result) {
        if(result != NSFileHandlingPanelOKButton) {
            return;
        }
        NSFileManager *fileManager = [NSFileManager new];
        NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *applicationFilesDirectory = [libraryURL URLByAppendingPathComponent:@"Core Data Editor"];
        if([fileManager fileExistsAtPath:applicationFilesDirectory.path] == NO) {
            [fileManager createDirectoryAtPath:applicationFilesDirectory.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSURL *modelURL = self.managedObjectModelURL;
        CDEManagedObjectSubclassesGenerator *generator = [[CDEManagedObjectSubclassesGenerator alloc] initWithOutputDirectory:[savePanel directoryURL] modelPath:modelURL applicationFilesDirectory:applicationFilesDirectory];
        generator.generateARCCompatibleCode = self.accessoryViewController.generateARCCompatibleCode.boolValue;
        generator.generateFetchResultsControllerCode = self.accessoryViewController.generateFetchResultsControllerCode.boolValue;
        [generator generate];
        [[NSWorkspace sharedWorkspace] selectFile:[generator.readmeURL path] inFileViewerRootedAtPath:@""];
        self.completionHandler ? self.completionHandler() : nil;
    }];
    
}

@end
