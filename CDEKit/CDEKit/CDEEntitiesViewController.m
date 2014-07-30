#import "CDEEntitiesViewController.h"
#import "CDEManagedObjectsViewController.h"
#import "CDE+Private.h"


@interface CDEEntitiesViewController ()
@property (nonatomic, strong) NSEntityDescription *selectedEntityDescription;
@end

@implementation CDEEntitiesViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.tableView reloadData];
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)dismissCoreDataEditor:(id)sender {
  [[CDE sharedCoreDataEditor].managedObjectContext save:NULL];
  [self.navigationController dismissViewControllerAnimated:YES completion:^{
    
  }];
}

#pragma mark - Storyboarding
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if([segue.identifier isEqualToString:@"showManagedObjects"]) {
    CDEManagedObjectsViewController *managedObjectsViewController = segue.destinationViewController;
    managedObjectsViewController.managedObjectContext = [CDE sharedCoreDataEditor].managedObjectContext;
    managedObjectsViewController.entityDescription = [self entityDescriptionAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [managedObjectsViewController updateUI];
  }
  [super prepareForSegue:segue sender:sender];
}

#pragma mark - Helper
- (NSEntityDescription *)entityDescriptionAtIndexPath:(NSIndexPath *)indexPath {
  return [CDE sharedCoreDataEditor].managedObjectModel.entities[indexPath.row];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [CDE sharedCoreDataEditor].managedObjectModel.entities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"CDEEntityCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  NSEntityDescription *entity = [self entityDescriptionAtIndexPath:indexPath];
  cell.textLabel.text = entity.name;
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
  self.selectedEntityDescription = [self entityDescriptionAtIndexPath:indexPath];
  // Navigation logic may go here. Create and push another view controller.
  /*
   <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
   // ...
   // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   */
}

@end
