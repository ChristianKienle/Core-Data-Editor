#import <Foundation/Foundation.h>

// see: http://stackoverflow.com/questions/15613794/nsfilecoordinator-correct-usage-for-sqlite-journal-file-in-sandbox-mac-app-store

@interface SQLiteRelatedItemPresenter : NSObject <NSFilePresenter> {
    NSURL *primaryPresentedItemURL;
    NSURL *presentedItemURL;
}

+ (void)addPresentersForURL:(NSURL *)databaseURL;
+ (void)removeFilePresentersForURL:(NSURL *)databaseURL;

@end
