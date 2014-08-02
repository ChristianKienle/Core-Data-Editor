#import "CDECodeGeneratorAccessoryViewController.h"

@interface CDECodeGeneratorAccessoryViewController ()

@end

@implementation CDECodeGeneratorAccessoryViewController


#pragma mark Creating an Instance
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:@"CDECodeGeneratorAccessoryViewController" bundle:nil];
   if(self) {
       self.generateARCCompatibleCode = @YES;
       self.generateFetchResultsControllerCode = @YES;
   }
   return self;
}

- (instancetype)init {
   return [self initWithNibName:nil bundle:nil];
}

@end
