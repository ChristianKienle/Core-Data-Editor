#import "CDEStringAttributeViewController.h"

@implementation CDEStringAttributeViewController

#pragma mark CMKViewController
- (NSString *)nibName {
  return @"CDEStringAttributeView";
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
  NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[[self attributeDescription] validationPredicates]];
  if([predicate evaluateWithObject:[fieldEditor string]] == YES) {
    return YES;
  }
  
  NSAlert *alert = [[NSAlert alloc] init];
  alert.informativeText = [NSString stringWithFormat:@"Input '%@' does not match validation predicates:\n\n%@", [fieldEditor string], [predicate description]];
  alert.messageText = @"Validation Error";
  [alert runModal];
  
  return NO;
}

@end
