#import "SQLiteRelatedItemPresenter.h"

static NSOperationQueue *_presentedItemOperationQueue;

@interface SQLiteRelatedItemPresenter ()

#pragma mark - Properties
@property (nonatomic, copy) NSURL *fileURL;

@end

@implementation SQLiteRelatedItemPresenter

#pragma mark - NSObject
+ (void)initialize {
    [super initialize];
    if(_presentedItemOperationQueue == nil) {
        _presentedItemOperationQueue = [[NSOperationQueue alloc] init];
        _presentedItemOperationQueue.maxConcurrentOperationCount = 1;
    }
}

+ (void)addPresentersForURL:(NSURL *)databaseURL {
    SQLiteRelatedItemPresenter *p1, *p2, *p3, *p4;
    
    p1 =[[SQLiteRelatedItemPresenter alloc] initWithFileURL:databaseURL prefix:nil suffix:@"-wal"];
    [NSFileCoordinator addFilePresenter:p1];
    p2 = [[SQLiteRelatedItemPresenter alloc] initWithFileURL:databaseURL prefix:nil suffix:@"-shm"];
    [NSFileCoordinator addFilePresenter:p2];
    p3 = [[SQLiteRelatedItemPresenter alloc] initWithFileURL:databaseURL prefix:nil suffix:@"-journal"];
    [NSFileCoordinator addFilePresenter:p3];
    p4 = [[SQLiteRelatedItemPresenter alloc] initWithFileURL:databaseURL prefix:@"." suffix:@"-conch"];
    [NSFileCoordinator addFilePresenter:p4];
    
    // +filePresenters will only return once the asynchronously added file presenters are done being registered
    [NSFileCoordinator filePresenters];
}

+ (void)removeFilePresentersForURL:(NSURL *)databaseURL {
    NSMutableArray *filePresentersToRemove = [NSMutableArray new];
    for(id <NSFilePresenter> presenter in [NSFileCoordinator filePresenters]) {
        if([presenter isKindOfClass:self] == NO) {
            continue;
        }
        SQLiteRelatedItemPresenter *SQLPresenter = (SQLiteRelatedItemPresenter *)presenter;
        if([SQLPresenter.fileURL isEqual:databaseURL] == NO) {
            continue;
        }
        [filePresentersToRemove addObject:presenter];
    }
    for(id <NSFilePresenter> presenter in filePresentersToRemove) {
        [NSFileCoordinator removeFilePresenter:presenter];
    }
}

- initWithFileURL:(NSURL *)fileURL prefix:(NSString *)prefix suffix:(NSString *)suffix {
    self = [super init];
    if (self) {
        self.fileURL = fileURL;
        primaryPresentedItemURL = fileURL;
        NSString *path = [fileURL path];
        if (prefix) {
            NSString *name = [path lastPathComponent];
            NSString *dir = [path stringByDeletingLastPathComponent];
            path = [dir stringByAppendingPathComponent:[prefix stringByAppendingString:name]];
        }
        if (suffix) {
            path = [path stringByAppendingString:suffix];
        }
        presentedItemURL = [NSURL fileURLWithPath:path];
    }
    return self;
}

- (NSURL *)presentedItemURL {
    return presentedItemURL;
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return _presentedItemOperationQueue;
}

- (NSURL *)primaryPresentedItemURL {
    return primaryPresentedItemURL;
}

@end
