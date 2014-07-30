#import "CDEManagedObjectsViewController.h"
#import "CDE+Private.h"
#import "NSManagedObjectID+CDEAdditions.h"
#import "CDEManagedObjectViewController.h"

@interface CDEManagedObjectsViewController ()

#pragma mark - Properties
@property (nonatomic, copy) NSArray *fetchedResults; // atm NSManagedObjectIDs
//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation CDEManagedObjectsViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
      self.fetchedResults = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//  fetchRequest.fetchBatchSize = 20;
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
  NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:self.entityDescription.name inManagedObjectContext:self.managedObjectContext];
  NSMutableArray *objectIDs = [self.fetchedResults mutableCopy];
  [objectIDs addObject:object.objectID];
  self.fetchedResults = objectIDs;
  [self.tableView reloadData];
  NSLog(@"adding");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
