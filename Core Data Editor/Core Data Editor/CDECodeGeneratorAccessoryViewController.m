#import "CDECodeGeneratorAccessoryViewController.h"

@interface CDECodeGeneratorAccessoryViewController ()

@end

@implementation CDECodeGeneratorAccessoryViewController


#pragma mark Creating an Instance
<<<<<<< HEAD
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:@"CDECodeGeneratorAccessoryViewController" bundle:nil];
=======
- (instancetype)init {
   self = [self initWithNibName:@"CDECodeGeneratorAccessoryViewController" bundle:nil];
>>>>>>> 65ba89d7421433954f4d462d9419443797f8901d
   if(self) {
       self.generateARCCompatibleCode = @YES;
       self.generateFetchResultsControllerCode = @YES;
   }
   return self;
}

<<<<<<< HEAD
- (instancetype)init {
   return [self initWithNibName:nil bundle:nil];
=======
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
>>>>>>> 65ba89d7421433954f4d462d9419443797f8901d
}

@end
