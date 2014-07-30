#import <Foundation/Foundation.h>

@interface CDEManagedObjectSubclassesGenerator : NSObject

#pragma mark Creating
- (instancetype)initWithOutputDirectory:(NSURL *)initOutputDirectory modelPath:(NSURL *)initModelPath applicationFilesDirectory:(NSURL *)initApplicationFilesDirectory;

#pragma mark Properties
@property (nonatomic, copy, readonly) NSURL *outputDirectory;
@property (nonatomic, copy, readonly) NSURL *modelPath;
@property (nonatomic, copy, readonly) NSURL *applicationFilesDirectory;
@property (nonatomic, readonly) NSURL *readmeURL;
@property (nonatomic, assign) BOOL generateARCCompatibleCode;
@property (assign) BOOL generateFetchResultsControllerCode;

#pragma mark Generate the Subclasses
- (void)generate;

@end
