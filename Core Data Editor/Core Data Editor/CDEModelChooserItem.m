#import "CDEModelChooserItem.h"

@interface CDEModelChooserItem ()

#pragma mark Properties
@property (nonatomic, readwrite, copy) NSString *titleForDisplay;
@property (nonatomic, readwrite, copy) NSURL *URL;
@property (nonatomic, readwrite, retain) NSManagedObjectModel *managedObjectModel;

@end

@implementation CDEModelChooserItem

#pragma mark Properties
@synthesize titleForDisplay, URL, managedObjectModel;

#pragma mark Creating
- (id)initWithTitleForDisplay:(NSString *)initTitleForDisplay URL:(NSURL *)initURL managedObjectModel:(NSManagedObjectModel *)initManagedObjectModel {
   if(initTitleForDisplay == nil || initURL == nil || initManagedObjectModel == nil) {
      self = nil;
      return nil;
   }
   self = [super init];
   if(self) {
      self.titleForDisplay = initTitleForDisplay;
      self.URL = initURL;
      self.managedObjectModel = initManagedObjectModel;
   }
   return self;
}

- (id)init {
   return [self initWithTitleForDisplay:[NSString string] URL:nil managedObjectModel:nil];
}

@end
