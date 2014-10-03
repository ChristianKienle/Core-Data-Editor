#import "CDEManagedObjectSubclassesGenerator.h"

@interface CDEManagedObjectSubclassesGenerator ()

#pragma mark Properties
@property (nonatomic, copy, readwrite) NSURL *outputDirectory;
@property (nonatomic, copy, readwrite) NSURL *modelPath;
@property (nonatomic, copy, readwrite) NSURL *applicationFilesDirectory;

#pragma mark Private Methods
- (NSString *)mogeneratorTemplatesDirectory;
- (void)createTemplateFolderAndCopyTemplatesIfNeeded;
- (void)checkIfBundleResource:(NSString *)resource ofType:(NSString *)type existsInDirectoryAndCopyIfNeeded:(NSString *)directory;

@end

@implementation CDEManagedObjectSubclassesGenerator

#pragma mark Creating
- (instancetype)initWithOutputDirectory:(NSURL *)initOutputDirectory modelPath:(NSURL *)initModelPath applicationFilesDirectory:(NSURL *)initApplicationFilesDirectory {
    if(initOutputDirectory == nil || initModelPath == nil || initApplicationFilesDirectory == nil) {
        self = nil;
        return nil;
    }
    self = [super init];
    if(self) {
        self.generateARCCompatibleCode = YES;
        self.generateFetchResultsControllerCode = YES;
        self.outputDirectory = initOutputDirectory;
        self.modelPath = initModelPath;
        self.applicationFilesDirectory = initApplicationFilesDirectory;
    }
    return self;
}

- (instancetype)init {
    return [self initWithOutputDirectory:nil modelPath:nil applicationFilesDirectory:nil];
}

#pragma mark Properties
- (NSURL *)readmeURL {
    return [NSURL fileURLWithPath:[self.outputDirectory.path stringByAppendingPathComponent:@"Read me.rtf"]];
}

#pragma mark Generate the Subclasses
- (void)generate {
    [self createTemplateFolderAndCopyTemplatesIfNeeded];
    @try {
        NSString *mogeneratorBinaryPath = [[NSBundle mainBundle] pathForResource:@"mogenerator" ofType:[NSString string]];
		NSTask *task = [NSTask new];
		[task setLaunchPath:mogeneratorBinaryPath];
        NSString *outputMachinePath = [self.outputDirectory.path stringByAppendingPathComponent:@"Machine"];
        NSString *outputHumanPath = [self.outputDirectory.path stringByAppendingPathComponent:@"Human"];
        
        NSMutableArray *arguments = [@[@"-m", self.modelPath.path, @"-M", outputMachinePath, @"-H", outputHumanPath] mutableCopy];
        
        if(self.generateARCCompatibleCode) {
            [arguments addObject:@"--template-var"];
            [arguments addObject:@"arc=true"];
        }
        
        if(self.generateFetchResultsControllerCode) {
            [arguments addObject:@"--template-var"];
            [arguments addObject:@"frc=true"];
        }
        
        [task setArguments:arguments];
		
		NSPipe *pipe = [NSPipe pipe];
		[task setStandardOutput:pipe];
		[task setStandardInput:[NSPipe pipe]];
		[task launch];
		
	} @catch(NSException *ex) {
		NSLog(@"WARNING couldn't launch mogenerator\n");
	}
    
    NSFileManager *fileManager = [NSFileManager new];
    NSString *sourceReadmePath = [[NSBundle mainBundle] pathForResource:@"mogeneratorReadme" ofType:@"rtf"];
    NSString *destinationReadmePath = [self.outputDirectory.path stringByAppendingPathComponent:@"Read me.rtf"];
    [fileManager copyItemAtPath:sourceReadmePath toPath:destinationReadmePath error:nil];
}

#pragma mark Dealloc
- (void)dealloc {
    self.outputDirectory = nil;
    self.modelPath = nil;
    self.applicationFilesDirectory = nil;
}

#pragma mark Private Methods

- (NSString *)mogeneratorTemplatesDirectory {
    return [self.applicationFilesDirectory.path stringByAppendingPathComponent:@"mogenerator-v-1-26-templates"];
}

- (void)createTemplateFolderAndCopyTemplatesIfNeeded {
    NSString *templateDirectoryPath = [self mogeneratorTemplatesDirectory];
    
    NSFileManager *fileManager = [NSFileManager new];
    if([fileManager fileExistsAtPath:templateDirectoryPath isDirectory:nil] == NO) {
        [fileManager createDirectoryAtPath:templateDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *motemplateType = @"motemplate";
    [self checkIfBundleResource:@"human.h" ofType:motemplateType existsInDirectoryAndCopyIfNeeded:templateDirectoryPath];
    [self checkIfBundleResource:@"human.m" ofType:motemplateType existsInDirectoryAndCopyIfNeeded:templateDirectoryPath];
    [self checkIfBundleResource:@"machine.h" ofType:motemplateType existsInDirectoryAndCopyIfNeeded:templateDirectoryPath];
    [self checkIfBundleResource:@"machine.m" ofType:motemplateType existsInDirectoryAndCopyIfNeeded:templateDirectoryPath];
}

- (void)checkIfBundleResource:(NSString *)resource ofType:(NSString *)type existsInDirectoryAndCopyIfNeeded:(NSString *)directory {
    //   NSBundle *bundle = [NSBundle mainBundle];
    //   NSString *destinationTemplatePath = [directory stringByAppendingPathComponent:[resource stringByAppendingPathExtension:type]];
    //    NSFileManager *fileManager = [NSFileManager new];
    //   BOOL copyFile = ![fileManager fileExistsAtPath:destinationTemplatePath isDirectory:nil];
    //   if(copyFile) {
    //      [fileManager copyItemAtPath:[bundle pathForResource:resource ofType:type] toPath:destinationTemplatePath error:nil];
    //   }
    
}

@end
