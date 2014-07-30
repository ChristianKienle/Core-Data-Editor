#import "CDEManagedObjectViewController.h"
#import "CDEPropertyTableViewCell.h"

@interface CDEManagedObjectViewController ()
@property (nonatomic, copy) NSArray *propertyDescriptions;
@end

@implementation CDEManagedObjectViewController

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

#pragma mark - Working with the UI
- (void)updateUI {
  self.title = [self.managedObject.objectID humanReadableRepresentationByHidingEntityName_cde:NO];
  self.propertyDescriptions = @[];

  NSMutableArray *propertyDescriptions = [NSMutableArray new];
  [self.managedObject.entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSAttributeDescription *attribute, BOOL *stop) {
    NSAttributeType type = attribute.attributeType;
    if((type == NSStringAttributeType) || (type == NSBooleanAttributeType) || (CDEIsIntegerAttributeType(type)) || CDEIsFloatingPointAttributeType(type) || type == NSDateAttributeType) {
      [propertyDescriptions addObject:attribute];
    }
  }];
  self.propertyDescriptions = propertyDescriptions;
  
  [self.tableView reloadData];
}

#pragma mark - Helper
- (NSPropertyDescription *)propertyDescriptionAtIndexPath:(NSIndexPath *)indexPath {
  return self.propertyDescriptions[indexPath.row];
}

- (NSString *)cellIdentifierForPropertyDescription:(NSPropertyDescription *)propertyDescription {
  NSParameterAssert(propertyDescription);
  if(propertyDescription.isRelationshipDescription_cde) {
    return nil;
  }
  if(propertyDescription.isAttributeDescription_cde) {
    NSAttributeType type = [(NSAttributeDescription *)propertyDescription attributeType];
    if(type == NSStringAttributeType) {
      return @"CDEStringAttributeCell";
    }
    if(type == NSBooleanAttributeType) {
      return @"CDEBoolAttributeCell";
    }
    if(CDEIsIntegerAttributeType(type)) {
      return @"CDEIntegerAttributeCell";
    }
    if(CDEIsFloatingPointAttributeType(type)) {
      return @"CDEFloatAttributeCell";
    }
    if(type == NSDateAttributeType) {
      return @"CDEDateAttributeCell";
    }
  }
  return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.propertyDescriptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  //CDEBoolAttributeCell
  //CDEStringAttributeCell
//    static NSString *CellIdentifier = @"Cell";
  NSPropertyDescription *property = [self propertyDescriptionAtIndexPath:indexPath];
  NSString *identifier = [self cellIdentifierForPropertyDescription:property];
    CDEPropertyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
  cell.propertyDescription = property;
  cell.managedObject = self.managedObject;
  [cell updateUI];
//    cell.textLabel.text = @"hello";
    // Configure the cell...
    
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
