#import "CDEManagedObjectsViewController.h"
#import "CDE+Private.h"
#import "NSManagedObjectID+CDEAdditions.h"
#import "CDEManagedObjectViewController.h"

@interface CDEManagedObjectsViewController ()

#pragma mark - Properties
@property (nonatomic, copy) NSArray *fetchedResults;

@end

@implementation CDEManagedObjectsViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
      self.fetchedResults = @[];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateUI];
}

#pragma mark - Storyboarding
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if([segue.identifier isEqualToString:@"showManagedObject"]) {
    // Get the managed object
    NSManagedObjectID *objectID = [self objectIDAtIndexPath:[self.tableView indexPathForSelectedRow]];
    NSError *error = nil;
    NSManagedObject *object = [self.managedObjectContext existingObjectWithID:objectID error:&error];
    if(object == nil) {
      NSLog(@"[CDE] Cannot show managed object because: %@", error);
      [[CDE sharedCoreDataEditor] presentError:error];
      return;
    }
    CDEManagedObjectViewController *managedObjectViewController = segue.destinationViewController;
    managedObjectViewController.managedObject = object;
    [managedObjectViewController updateUI];
  }
  [super prepareForSegue:segue sender:sender];
}

#pragma mark - Working with the UI
- (void)updateUI {
  NSFetchRequest *fetchRequest = [NSFetchRequest new];
  fetchRequest.entity = self.entityDescription;
  fetchRequest.resultType = NSManagedObjectIDResultType;
  NSError *error = nil;
  self.fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  if(self.fetchedResults == nil) {
    NSLog(@"[CDE] Fetch error in updateUI: %@", error);
    self.fetchedResults = @[];
    [[CDE sharedCoreDataEditor] presentError:error];
    return;
  }
  [self.tableView reloadData];
}

#pragma mark - Helper
- (NSManagedObjectID *)objectIDAtIndexPath:(NSIndexPath *)indexPath {
  return self.fetchedResults[indexPath.row];
}

#pragma mark - Actions
- (IBAction)addManagedObject:(id)sender {
  NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:self.entityDescription.name
                                                          inManagedObjectContext:self.managedObjectContext];
  NSMutableArray *objectIDs = [self.fetchedResults mutableCopy];
  [objectIDs addObject:object.objectID];
  self.fetchedResults = objectIDs;
  [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"CDEManagedObjectIDCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  NSManagedObjectID *objectID = [self objectIDAtIndexPath:indexPath];
  cell.textLabel.text = [objectID humanReadableRepresentationByHidingEntityName_cde:YES];
  
  return cell;
}

#pragma mark - Table view delegate

@end
