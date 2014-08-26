#import "CDECodeGeneratorAccessoryViewController.h"

@interface CDECodeGeneratorAccessoryViewController ()

@end

@implementation CDECodeGeneratorAccessoryViewController


#pragma mark Creating an Instance
- (instancetype)init {
   self = [self initWithNibName:@"CDECodeGeneratorAccessoryViewController" bundle:nil];
   if(self) {
       self.generateARCCompatibleCode = @YES;
       self.generateFetchResultsControllerCode = @YES;
   }
   return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

@end
