#import <Cocoa/Cocoa.h>
#import "CMKViewController.h"

@protocol CDEAttributeViewControllerDelegate;

@interface CDEAttributeViewController : CMKViewController

#pragma mark Properties
@property (nonatomic, readonly, strong) NSManagedObject *managedObject;
@property (nonatomic, readonly, strong) NSAttributeDescription *attributeDescription;
@property (nonatomic, strong) id resultingValue;
@property (nonatomic, weak) IBOutlet NSView *attributeNameView;
@property (nonatomic, weak) IBOutlet NSTextField *attributeNameTextField;
@property (nonatomic, weak) IBOutlet NSView *valueView;
@property (nonatomic, weak) id<CDEAttributeViewControllerDelegate> delegate;

#pragma mark Creating
- (id)initWithManagedObject:(NSManagedObject *)managedObject
       attributeDescription:(NSAttributeDescription *)attributeDescription
                   delegate:(id<CDEAttributeViewControllerDelegate>)initDelegate;

+ (id)attributeViewControllerWithManagedObject:(NSManagedObject *)managedObject
                          attributeDescription:(NSAttributeDescription *)attributeDescription
                                      delegate:(id<CDEAttributeViewControllerDelegate>)initDelegate;

+ (Class)attributeViewControllerClassForAttributeDescription:(NSAttributeDescription *)attributeDescription;

#pragma mark Working with the Resulting value
- (void)didChangeResultingValue;

#pragma mark - UI
- (void)updateAttributeNameUI;

@end
