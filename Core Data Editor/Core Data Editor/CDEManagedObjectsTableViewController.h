#import <Cocoa/Cocoa.h>

@class CDEManagedObjectsRequest;
@interface CDEManagedObjectsTableViewController : NSViewController

#pragma mark Properties
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) CDEManagedObjectsRequest *request;

@end
