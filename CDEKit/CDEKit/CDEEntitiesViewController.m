#import "CDEEntitiesViewController.h"
#import "CDEManagedObjectsViewController.h"
#import "CDE+Private.h"


@interface CDEEntitiesViewController ()

@property (nonatomic, strong) NSEntityDescription *selectedEntityDescription;

@end

@implementation CDEEntitiesViewController

#pragma mark - Actions
- (IBAction)dismissCoreDataEditor:(id)sender {
  NSError *error;
  [[CDE sharedCoreDataEditor].managedObjectContext save:&error];
  if (error) {
    NSLog(@"Error: %@", error.localizedDescription);
  }
  
  [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Storyboarding
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if([segue.identifier isEqualToString:@"showManagedObjects"]) {
    CDEManagedObjectsViewController *managedObjectsViewController = segue.destinationViewController;
    managedObjectsViewController.managedObjectContext = [CDE sharedCoreDataEditor].managedObjectContext;
    managedObjectsViewController.entityDescription = [self entityDescriptionAtIndexPath:[self.tableView indexPathForSelectedRow]];
  }
  [super prepareForSegue:segue sender:sender];
}

#pragma mark - Helper
- (NSEntityDescription *)entityDescriptionAtIndexPath:(NSIndexPath *)indexPath {
  return [CDE sharedCoreDataEditor].managedObjectModel.entities[indexPath.row];
}

#pragma mark - Table view data source
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.selectedEntityDescription = [self entityDescriptionAtIndexPath:indexPath];
}

@end
