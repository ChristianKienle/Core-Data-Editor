#import "CDEGenerateThumbnailOperation.h"

NSString* const CDEGenerateThumbnailOperationDidGenerateThumbnailNotification = @"CDEGenerateThumbnailOperationDidGenerateThumbnailNotification";
NSString* const CDEGenerateThumbnailOperationDidGenerateThumbnailNotificationInputData = @"inputData";
NSString* const CDEGenerateThumbnailOperationDidGenerateThumbnailNotificationGeneratedThumbnail = @"generatedThumbnail";

@interface CDEGenerateThumbnailOperation ()

#pragma mark Properties
@property (nonatomic, copy, readwrite) NSData *data;

#pragma mark Private Methods
- (NSImage *)thumbnailForFile:(NSURL *)URL;
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
    return nil;
}

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
