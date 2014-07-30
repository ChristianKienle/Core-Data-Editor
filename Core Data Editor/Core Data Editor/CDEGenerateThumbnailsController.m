#import "CDEGenerateThumbnailsController.h"
#import "CDEGenerateThumbnailOperation.h"

@interface CDEGenerateThumbnailsController ()

#pragma mark Properties
@property (nonatomic, retain) NSOperationQueue *operationQueue;

@end

@implementation CDEGenerateThumbnailsController

#pragma mark Properties
@synthesize operationQueue;

#pragma mark Creating
- (id)init {
   self = [super init];
   if(self) {
       self.operationQueue = [NSOperationQueue new];
      self.operationQueue.name = @"com.christian-kienle.coredataeditor.generatethumbnailscontroller";
      self.operationQueue.maxConcurrentOperationCount = 2;
   }
   
   return self;
}

#pragma mark Dealloc
- (void)dealloc {
   [self.operationQueue cancelAllOperations];
   self.operationQueue = nil;
}

#pragma mark Generating Thumbnails
- (void)generateThumbnailForData:(NSData *)data {
   if(data == nil) {
      return;
   }
   CDEGenerateThumbnailOperation *operation = [[CDEGenerateThumbnailOperation alloc] initWithData:data];
   [self.operationQueue addOperation:operation];
}

@end
