#import <Foundation/Foundation.h>

@interface NSURL (CDEApplicationAnalyzer)

#pragma mark - Application Bundle Detection
@property (nonatomic, readonly, getter = isApplicationBundleURL_cde) BOOL isApplicationBundleURL_cde;

@end
