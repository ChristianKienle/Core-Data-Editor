#import <Foundation/Foundation.h>

@class CDEAttributeViewController;
@protocol CDEAttributeViewControllerDelegate <NSObject>

@required
- (void)attributeViewController:(CDEAttributeViewController *)attributeViewController didRequestGenerationOfThumbnailForData:(NSData *)inputData;

@end
