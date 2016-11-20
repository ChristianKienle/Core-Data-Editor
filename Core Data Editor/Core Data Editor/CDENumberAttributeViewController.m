#import "CDENumberAttributeViewController.h"
#import "CDEManagedObjectsTableViewAttributeHelper.h"

@implementation CDENumberAttributeViewController

#pragma mark CMKViewController
- (NSString *)nibName {
  return @"CDENumberAttributeView";
}

#pragma mark NSViewController
- (void)loadView {
  [super loadView];
  NSFormatter *formatter = [CDEManagedObjectsTableViewAttributeHelper formatterForAttributeType:self.attributeDescription.attributeType];
  [self.valueTextField setFormatter:formatter];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
  NSNumberFormatter *formatter = (NSNumberFormatter *)[CDEManagedObjectsTableViewAttributeHelper formatterForAttributeType:self.attributeDescription.attributeType];
  
  
  NSNumber *objectValue = [formatter numberFromString:[fieldEditor string]];
  if(objectValue == nil) {
    return YES;
  }
  NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[[self attributeDescription] validationPredicates]];
  
  if([predicate evaluateWithObject:objectValue] == YES) {
    return YES;
  }

  NSAlert *alert = [NSAlert new];
  alert.informativeText = [NSString stringWithFormat:@"Input '%@' does not match validation predicates:\n\n%@", [fieldEditor string], [predicate description]];
  alert.messageText = @"Validation Error";
  alert.alertStyle = NSAlertStyleCritical;
  [alert runModal];
  return NO;
}

@end
