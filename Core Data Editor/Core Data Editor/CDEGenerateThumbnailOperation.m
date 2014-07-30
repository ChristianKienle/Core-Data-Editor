#import "CDEGenerateThumbnailOperation.h"
//#import <QuickLook/QuickLook.h>

NSString* const CDEGenerateThumbnailOperationDidGenerateThumbnailNotification = @"CDEGenerateThumbnailOperationDidGenerateThumbnailNotification";
NSString* const CDEGenerateThumbnailOperationDidGenerateThumbnailNotificationInputData = @"inputData";
NSString* const CDEGenerateThumbnailOperationDidGenerateThumbnailNotificationGeneratedThumbnail = @"generatedThumbnail";

@interface CDEGenerateThumbnailOperation ()

#pragma mark Properties
@property (nonatomic, copy, readwrite) NSData *data;

#pragma mark Private Methods
- (NSImage *)thumbnailForFile:(NSURL *)URL;
//- (NSImage *)quickLookThumbnailForFile:(NSURL *)URL;
- (void)sendNotificationOnMainThreadWithResultingThumbnail:(NSImage *)thumbnail;

@end

@implementation CDEGenerateThumbnailOperation

#pragma mark Creating
- (id)initWithData:(NSData *)initData {
   self = [super init];
   if(self) {
      self.data = initData;
   }
   return self;
}

- (id)init {
   return [self initWithData:nil];
}

#pragma mark Properties
#pragma mark NSOperation
- (void)main {
    @autoreleasepool {
        if(self.data == nil) {
            return;
        }
        NSURL *dataURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]]];
        [self.data writeToURL:dataURL atomically:YES];
        NSImage *image = [self thumbnailForFile:dataURL];
        [self performSelectorOnMainThread:@selector(sendNotificationOnMainThreadWithResultingThumbnail:) withObject:image waitUntilDone:YES];

    }
}

#pragma mark Private Methods
- (NSImage *)thumbnailForFile:(NSURL *)URL {
   NSImage *naiveImage = [[NSImage alloc] initWithContentsOfURL:URL];
   if(naiveImage != nil) {
      return naiveImage;
   }
   
//   NSArray *extensions = [NSArray arrayWithObjects:@"png", @"tiff", @"rtf", nil];
//   for(NSString *extension in extensions) {
//      NSString *temporaryFilename = [[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] stringByAppendingPathExtension:extension];
//      NSURL *temporaryURL = [NSURL fileURLWithPath:temporaryFilename];
//      NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
//      BOOL copySuccessful = [fileManager copyItemAtURL:URL toURL:temporaryURL error:nil];
//      if(copySuccessful == NO) {
//         continue;
//      }
//
//      NSImage *resultingImage = [self quickLookThumbnailForFile:temporaryURL];
//      [fileManager removeItemAtURL:temporaryURL error:nil];
//      if(resultingImage == nil) {
//         continue;
//      }
//      return resultingImage;
//   }
    return nil;
   //return [[NSWorkspace sharedWorkspace] iconForFile:URL.path];
}

//- (NSImage *)quickLookThumbnailForFile:(NSURL *)URL {
//   CGImageRef image = QLThumbnailImageCreate(nil, (CFURLRef)URL , CGSizeMake(48.0, 48.0), nil);
//   if(image == NULL) {
//      return nil;
//   }
//   NSImage *nsimage = [[[NSImage alloc] initWithCGImage:image size:NSZeroSize] autorelease];
//   CGImageRelease(image);
//   return nsimage;
//}

- (void)sendNotificationOnMainThreadWithResultingThumbnail:(NSImage *)thumbnail {
   if(thumbnail == nil) {
      return;
   }
   NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
   userInfo[CDEGenerateThumbnailOperationDidGenerateThumbnailNotificationGeneratedThumbnail] = [thumbnail copy];
   userInfo[CDEGenerateThumbnailOperationDidGenerateThumbnailNotificationInputData] = [self.data copy];
   
   [[NSNotificationCenter defaultCenter] postNotificationName:CDEGenerateThumbnailOperationDidGenerateThumbnailNotification object:self userInfo:[userInfo copy]];
}

@end
