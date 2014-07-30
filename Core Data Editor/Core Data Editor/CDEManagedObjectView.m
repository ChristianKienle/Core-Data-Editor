#import "CDEManagedObjectView.h"
#import "CMKBindingSupport.h"
#import "CDEAttributeViewController.h"
#import "CDEFirstResponderWindow.h"
#import "CDEGenerateThumbnailsController.h"
#import "CDEGenerateThumbnailOperation.h"

static NSString *managedObjectObservationContext;

@interface CDEManagedObjectView()

#pragma mark Properties
@property (retain) NSMutableArray *attributeViewControllers;
@property (retain) NSDictionary *managedObjectBindingInfo;
@property (retain) CDEGenerateThumbnailsController *generateThumbnailsController;


#pragma mark Layout
- (void)layoutAttributeViews;

@end

@implementation CDEManagedObjectView

#pragma mark Keys, Contexts
+ (NSString *)managedObjectKey {
    return @"managedObject";
}

#pragma mark Creating
- (id)initWithFrame:(NSRect)frame {
   self = [super initWithFrame:frame];
   if(self) {
      self.managedObject = nil;
      self.managedObjectBindingInfo = nil;
      self.attributeViewControllers = [NSMutableArray array];
   }
   return self;
}

#pragma mark Awaking
- (void)awakeFromNib {
   if([super respondsToSelector:_cmd]) {
      [super awakeFromNib];
   }
   
   [self setAutoresizesSubviews:YES];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidMakeFirstResponder:) name:CDEFirstResponderWindowDidMakeFirstResponderNotification object:nil];
   
    self.generateThumbnailsController = [CDEGenerateThumbnailsController new];
}

- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self name:CDEFirstResponderWindowDidMakeFirstResponderNotification object:nil];
   for(CDEAttributeViewController *attributeViewController in self.attributeViewControllers) {
      attributeViewController.delegate = nil;
   }
   self.attributeViewControllers = nil;
   self.generateThumbnailsController = nil;
}

#pragma mark Handle CDEFirstResponderWindowDidMakeFirstResponderNotification
- (void)handleDidMakeFirstResponder:(NSNotification *)notification {
   if([self.window isEqualTo:notification.object] == NO) {
      return;
   }

   NSResponder *responder = (notification.userInfo)[CDEFirstResponderWindowDidMakeFirstResponderNotificationResponder];
   for(CDEAttributeViewController *attributeViewController in self.attributeViewControllers) {
      if([responder isEqualTo:attributeViewController.valueView]) {
         [[self.enclosingScrollView documentView] scrollRectToVisible:attributeViewController.view.frame];
      }
   }
}

#pragma mark NSView
- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
//    NSColor *backgroundColor = [NSColor redColor];

    NSColor *backgroundColor = [NSColor colorWithCalibratedWhite:0.907 alpha:1.000];
    [backgroundColor setFill ];
    NSRectFill(self.bounds);
}

#pragma mark Binding Support
- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
    if([binding isEqualToString:[[self class] managedObjectKey]]) {       
        [self setManagedObjectBindingInfo:@{NSObservedObjectKey: observableController, NSObservedKeyPathKey: keyPath, NSOptionsKey: options}];
        [observableController addObserver:self forKeyPath:keyPath options:0 context:&managedObjectObservationContext];
        return;
    }
    [super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}

- (NSDictionary *)infoForBinding:(NSString *)bindingName {
    if([bindingName isEqualToString:[[self class] managedObjectKey]]) {
        return [self managedObjectBindingInfo];
    }
	return [super infoForBinding:bindingName];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context == &managedObjectObservationContext) {
        if([CMKBindingSupport valueIsSingleValueMarker:[object valueForKeyPath:keyPath]] == NO) {
            [self setManagedObject:nil];
            [self refresh];
            return;
        }   
        
        [self setManagedObject:[object valueForKeyPath:keyPath]];
        [self refresh];
        return;
    }
   
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)refresh {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
   
   for(CDEAttributeViewController *attributeViewController in self.attributeViewControllers) {
      attributeViewController.delegate = nil;
   }
   
   [self.attributeViewControllers removeAllObjects];
   for(NSAttributeDescription *attributeDescription in [[[[self managedObject] entity] attributesByName] allValues]) {
      Class controllerClass = [CDEAttributeViewController attributeViewControllerClassForAttributeDescription:attributeDescription];
      if(controllerClass == nil) {
         continue;
      }
      CDEAttributeViewController *attributeViewController = [CDEAttributeViewController attributeViewControllerWithManagedObject:[self managedObject] attributeDescription:attributeDescription delegate:self];
       [attributeViewController view];
       attributeViewController.delegate = self;
//
      [self.attributeViewControllers addObject:attributeViewController];
      [self addSubview:[attributeViewController view]];  
      if([attributeViewController attributeNameView] != nil) {
         [self addSubview:[attributeViewController attributeNameView]];  
      }
    }
    [self layoutAttributeViews];
    
    NSUInteger attributeViewControllerIndex = 0;
    for(CDEAttributeViewController *attributeViewController in self.attributeViewControllers) {
        if((attributeViewControllerIndex + 1) < [self.attributeViewControllers count]) {
            CDEAttributeViewController *nextAttributeViewController = (self.attributeViewControllers)[attributeViewControllerIndex+1];
            [[attributeViewController view] setNextKeyView:[attributeViewController valueView]];
            [[attributeViewController valueView] setNextKeyView:[nextAttributeViewController view]];
        }
        if(attributeViewControllerIndex + 1 == [self.attributeViewControllers count]) {
            CDEAttributeViewController *nextAttributeViewController = (self.attributeViewControllers)[0];
            [[attributeViewController view] setNextKeyView:[attributeViewController valueView]];
            [[attributeViewController valueView] setNextKeyView:[nextAttributeViewController view]];
        }
        
        attributeViewControllerIndex++;
    }        
            
    [self setNeedsDisplay:YES];
}

#pragma mark - UI
- (void)updateDisplayedNames {
    for(CDEAttributeViewController *controller in self.attributeViewControllers) {
        [controller updateAttributeNameUI];
    }
}

#pragma mark - NSView
- (BOOL)isFlipped {
    return YES;
}

- (void)layoutAttributeViews {
   NSUInteger attributeViewControllerIndex = 0;
   CGFloat height = 10.0f;
   CGFloat nameViewWidthScaleFactor = 0.35;
   CGFloat valueViewWidthScaleFactor = 1.0 - nameViewWidthScaleFactor;
   for(CDEAttributeViewController *attributeViewController in self.attributeViewControllers) {
      NSRect newValueFrame = NSMakeRect(nameViewWidthScaleFactor * NSWidth([self bounds]), height, valueViewWidthScaleFactor * NSWidth([self bounds]) - 10.0, NSHeight([[attributeViewController view] frame]));
        if([attributeViewController attributeNameView] != nil) {
            NSRect newAttributeFrame = NSMakeRect(0.0f, height, nameViewWidthScaleFactor * NSWidth([self bounds]), NSHeight(newValueFrame));
            [[attributeViewController attributeNameView] setFrame:newAttributeFrame];
        }
        [[attributeViewController view] setFrame:newValueFrame];
        attributeViewControllerIndex++;
        height += NSHeight(newValueFrame);
    }    
    [self setFrameSize:NSMakeSize(NSWidth([self bounds]), MAX(height, NSHeight([self visibleRect])))];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
    [self layoutAttributeViews];
}

#pragma mark CDEAttributeViewControllerDelegate
- (void)attributeViewController:(CDEAttributeViewController *)attributeViewController didRequestGenerationOfThumbnailForData:(NSData *)inputData {
   [self.generateThumbnailsController generateThumbnailForData:inputData];
}

@end
