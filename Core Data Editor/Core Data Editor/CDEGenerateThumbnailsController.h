#import <Foundation/Foundation.h>

@interface CDEGenerateThumbnailsController : NSObject {
   @private
   NSOperationQueue *operationQueue;
}

#pragma mark Generating Thumbnails
- (void)generateThumbnailForData:(NSData *)data;

@end
