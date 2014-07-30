#import <Foundation/Foundation.h>

@interface CDEProjectBrowserItem : NSObject

#pragma mark - Creating
- (instancetype)initWithStorePath:(NSString *)path modelPath:(NSString *)modelPath;

#pragma mark - Properties
@property (nonatomic, readonly, copy) NSString *storePath;
@property (nonatomic, readonly, copy) NSString *modelPath;

@end