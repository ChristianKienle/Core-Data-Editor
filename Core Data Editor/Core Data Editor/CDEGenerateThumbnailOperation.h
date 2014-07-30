#import <Foundation/Foundation.h>

extern NSString* const CDEGenerateThumbnailOperationDidGenerateThumbnailNotification;
extern NSString* const CDEGenerateThumbnailOperationDidGenerateThumbnailNotificationInputData;
extern NSString* const CDEGenerateThumbnailOperationDidGenerateThumbnailNotificationGeneratedThumbnail;

@interface CDEGenerateThumbnailOperation : NSOperation

#pragma mark Creating
- (id)initWithData:(NSData *)initData;

#pragma mark Properties
@property (nonatomic, copy, readonly) NSData *data;

@end
