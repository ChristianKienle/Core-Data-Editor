#import "CDEManagedObjectViewController.h"
#import "CDEPropertyTableViewCell.h"
#import "CDE+Private.h"

@interface CDEManagedObjectViewController ()
@property (nonatomic, copy) NSArray *propertyDescriptions;
@end

@implementation CDEManagedObjectViewController

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

- (IBAction)didTapDelete:(id)sender {
  [[CDE sharedCoreDataEditor].managedObjectContext deleteObject:self.managedObject];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

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
  
    return cell;
}

@end
