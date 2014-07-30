#import "CDEPreferencesWindowController.h"
#import "NSUserDefaults+CDEAdditions.h"
#import "NSURL+CDEAdditions.h"

#import "CDEPreferencesAutomaticProjectCreationViewController.h"

@interface CDEPreferencesWindowController ()

#pragma mark - Properties
@property (nonatomic, copy) CDEPreferencesWindowControllerCompletionHandler completionHandler;

#pragma mark - Tabbed Preferences
@property (nonatomic, strong, readwrite) NSArray *viewControllers;
@property (nonatomic, strong) NSViewController *currentViewController;
@property (nonatomic, strong) NSToolbarItem *currentToolbarItem;


@end

@implementation CDEPreferencesWindowController

#pragma mark - Creating
- (instancetype)init {
    self = [super initWithWindowNibName:@"CDEPreferencesWindowController"];
    if(self) {
        
    }
    return self;
}

#pragma mark - NSWindowController
- (void)windowDidLoad {
    [super windowDidLoad];
    [self createToolbarItemsToViewControllerMapping];
}

#pragma mark - Showing the Preferences Window
- (void)showWithCompletionHandler:(CDEPreferencesWindowControllerCompletionHandler)handler {
    self.completionHandler = handler;
    [self showWindow:self];
}

- (void)showAutomaticProjectCreationPreferencesAndDisplayInfoSheetWithCompletionHandler:(CDEPreferencesWindowControllerCompletionHandler)handler {
    [self showAutomaticProjectCreationPreferencesWithCompletionHandler:handler];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *identifier = NSStringFromClass([CDEPreferencesAutomaticProjectCreationViewController class]);
        CDEPreferencesAutomaticProjectCreationViewController *viewController = (CDEPreferencesAutomaticProjectCreationViewController *)[self existingViewControllerForToolbarItemWithIdentifier:identifier];
        [viewController displayInfoSheet];
    });
}

- (void)showAutomaticProjectCreationPreferencesWithCompletionHandler:(CDEPreferencesWindowControllerCompletionHandler)handler {
    self.completionHandler = handler;
    [self showWindow:self];
    NSString *identifier = NSStringFromClass([CDEPreferencesAutomaticProjectCreationViewController class]);
    CDEPreferencesAutomaticProjectCreationViewController *viewController = (CDEPreferencesAutomaticProjectCreationViewController *)[self existingViewControllerForToolbarItemWithIdentifier:identifier];
    [self showViewController:viewController];
}

- (IBAction)dismiss:(id)sender {
    [self.window performClose:self];
}

- (void)windowWillClose:(NSNotification *)notification {
    self.completionHandler ? self.completionHandler() : nil;
}

#pragma mark - Tabbed Preferences
- (void)createToolbarItemsToViewControllerMapping {
    self.viewControllers = @[];
    
    if(self.window == nil) {
        NSLog(@"A preferences controller cannot work without a window. Connect the window outlet to your preferences window.");
        return;
    }
    if(self.window.toolbar == nil) {
        NSLog(@"A preferences controller cannot work without a toolbar.");
        return;
    }
    
    NSToolbarItem *firstItem = nil;
    for(NSToolbarItem *visibleItem in self.window.toolbar.visibleItems) {
        if(!visibleItem.isEnabled || visibleItem.target != self) {
            continue;
        }
        NSViewController *controller = [self createViewControllerForToolbarItem:visibleItem];
        if(controller == nil) {
            continue;
        }
        self.viewControllers = [self.viewControllers arrayByAddingObject:controller];
        if(firstItem == nil) {
            firstItem = visibleItem;
        }
    }
    if(firstItem != nil) {
        [self.window.toolbar setSelectedItemIdentifier:firstItem.itemIdentifier];
        [self showPreferencesFor:firstItem];
    }
}

- (NSViewController *)createViewControllerForToolbarItem:(NSToolbarItem *)item {
    if(item == nil) {
        return nil;
    }
    NSString *identifier = item.itemIdentifier;
    NSViewController *result = [[NSClassFromString(identifier) alloc] initWithNibName:identifier bundle:nil];
    if(result == nil) {
        return nil;
    }
    [result view];
    return result;
}

- (NSViewController *)existingViewControllerForToolbarItemWithIdentifier:(NSString *)identifier {
    if(identifier == nil) {
        return nil;
    }
    for(NSViewController *viewController in self.viewControllers) {
        if([viewController.nibName isEqualToString:identifier]) {
            return viewController;
        }
    }
    return nil;
}

- (NSViewController *)existingViewControllerForToolbarItem:(NSToolbarItem *)item {
    return [self existingViewControllerForToolbarItemWithIdentifier:item.itemIdentifier];
}

- (void)showViewController:(NSViewController *)newViewController {
    if(self.currentViewController == nil) {
        CGFloat deltaHeight = NSHeight([self.window.contentView bounds]) - NSHeight(newViewController.view.frame);
        CGFloat deltaWidth = NSWidth([self.window.contentView bounds]) - NSWidth(newViewController.view.frame);
        
        NSRect newWindowFrame = self.window.frame;
        
        newWindowFrame.size.height -= deltaHeight;
        newWindowFrame.size.width -= deltaWidth;
        newWindowFrame.origin.y += deltaHeight;
        [self.window setFrame:newWindowFrame display:YES animate:YES];
        [self.window.contentView addSubview:newViewController.view];
        
        self.currentViewController = newViewController;
        [self.window.toolbar setSelectedItemIdentifier:NSStringFromClass([newViewController class])];
        return;
    }
    
    [self.currentViewController.view removeFromSuperview];
    
    CGFloat deltaHeight = NSHeight(self.currentViewController.view.frame) - NSHeight(newViewController.view.frame);
    CGFloat deltaWidth = NSWidth(self.currentViewController.view.frame) - NSWidth(newViewController.view.frame);
    
    NSRect newWindowFrame = self.window.frame;
    
    newWindowFrame.size.height -= deltaHeight;
    newWindowFrame.size.width -= deltaWidth;
    newWindowFrame.origin.y += deltaHeight;
    [self.window setFrame:newWindowFrame display:YES animate:YES];
    [self.window.contentView addSubview:newViewController.view];
    self.currentViewController = newViewController;
    [self.window.toolbar setSelectedItemIdentifier:NSStringFromClass([newViewController class])];
}
- (IBAction)showPreferencesFor:(id)sender {
    NSViewController *newViewController = [self existingViewControllerForToolbarItem:sender];
    [self showViewController:newViewController];
}


@end
