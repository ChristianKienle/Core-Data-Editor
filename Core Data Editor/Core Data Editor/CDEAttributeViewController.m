#import "CDEAttributeViewController.h"
#import "CDEStringAttributeViewController.h"
#import "CDEManagedObjectsTableViewAttributeHelper.h"
#import "CDENumberAttributeViewController.h"
#import "CDEBooleanAttributeViewController.h"
#import "CDEDateAttributeViewController.h"
#import "CDEBinaryAttributeViewController.h"

const static NSString *CDEAttributeViewControllerResultingValueObservationContext = @"CDEAttributeViewControllerResultingValueObservationContext";

NSString* const CDEAttributeViewControllerResultingValueKey = @"resultingValue";

@interface CDEAttributeViewController()

#pragma mark Properties
@property (nonatomic, readwrite, strong) NSManagedObject *managedObject;
@property (nonatomic, readwrite, strong) NSAttributeDescription *attributeDescription;
    
@end

@implementation CDEAttributeViewController

#pragma mark CMKViewController
- (NSString *)nibName {
    return @"";
}

#pragma mark Creating
- (id)init {
    return [self initWithManagedObject:nil attributeDescription:nil delegate:nil];
}

- (id)initWithManagedObject:(NSManagedObject *)initManagedObject attributeDescription:(NSAttributeDescription *)initAttributeDescription delegate:(id<CDEAttributeViewControllerDelegate>)initDelegate {
   if(initManagedObject == nil || initAttributeDescription == nil) {
      self = nil;
      return nil;
   }
   
   self = [super init];
   
   if(self) {
      [self setManagedObject:initManagedObject];
      [self setAttributeDescription:initAttributeDescription];
      self.delegate = initDelegate;
      [self addObserver:self forKeyPath:[NSString stringWithFormat:@"managedObject.%@", [[self attributeDescription] name]] options:0 context:(__bridge void *)(CDEAttributeViewControllerResultingValueObservationContext)];
      [self didChangeResultingValue];
   }
      
   return self;
}

+ (Class)attributeViewControllerClassForAttributeDescription:(NSAttributeDescription *)attributeDescription {
    if([attributeDescription attributeType] == NSStringAttributeType) {
        return [CDEStringAttributeViewController class];
    }
    if([attributeDescription attributeType] == NSBooleanAttributeType) {
        return [CDEBooleanAttributeViewController class];
    }
   if([attributeDescription attributeType] == NSBinaryDataAttributeType) {

//    if([attributeDescription attributeType] == NSBinaryDataAttributeType || [attributeDescription attributeType] == NSTransformableAttributeType) {
        return [CDEBinaryAttributeViewController class];
    }
    if([attributeDescription attributeType] == NSDateAttributeType) {
        return [CDEDateAttributeViewController class];
    }
    if([CDEManagedObjectsTableViewAttributeHelper attributeTypeIsNumber:[attributeDescription attributeType]]) {
        return [CDENumberAttributeViewController class];
    }
    return nil;
}

+ (id)attributeViewControllerWithManagedObject:(NSManagedObject *)initManagedObject attributeDescription:(NSAttributeDescription *)initAttributeDescription delegate:(id<CDEAttributeViewControllerDelegate>)initDelegate {
    Class controllerClass = [self attributeViewControllerClassForAttributeDescription:initAttributeDescription];
    return [[controllerClass alloc] initWithManagedObject:initManagedObject attributeDescription:initAttributeDescription delegate:initDelegate];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context == (__bridge void *)(CDEAttributeViewControllerResultingValueObservationContext)) {
        [self willChangeValueForKey:CDEAttributeViewControllerResultingValueKey];
        [[self managedObject] setPrimitiveValue:[object valueForKeyPath:keyPath] forKey:[[self attributeDescription] name]];
        [self didChangeValueForKey:CDEAttributeViewControllerResultingValueKey];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark Properties
- (id)resultingValue {
    return [[self managedObject] valueForKey:[[self attributeDescription] name]];
}

- (void)setResultingValue:(id)newValue {
   BOOL fireDidChangeNotification = !([[self resultingValue] isEqualTo:newValue]); 
   [self willChangeValueForKey:CDEAttributeViewControllerResultingValueKey];
   [[self managedObject] setValue:newValue forKey:[[self attributeDescription] name]];
   [self didChangeValueForKey:CDEAttributeViewControllerResultingValueKey];
   
   if(fireDidChangeNotification) {
      [self didChangeResultingValue];
   }
}

#pragma mark Working with the Resulting value
- (void)didChangeResultingValue { }

#pragma mark - UI
- (void)updateAttributeNameUI {
    self.attributeNameTextField.stringValue = self.attributeDescription.nameForDisplay_cde;
}

#pragma mark NSObject
- (void)dealloc {
   self.delegate = nil;
   if([self managedObject] != nil || [self attributeDescription] != nil) {
      [self removeObserver:self forKeyPath:[NSString stringWithFormat:@"managedObject.%@", [[self attributeDescription] name]]];
   }
}


@end
