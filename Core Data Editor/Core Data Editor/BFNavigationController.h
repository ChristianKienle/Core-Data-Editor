//
//  BFNavigationController.h
//
//  Created by Heiko Dreyer on 26.04.12.
//  Copyright (c) 2012 boxedfolder.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BFNavigationController;

@protocol BFNavigationControllerDelegate <NSObject>

///---------------------------------------------------------------------------------------
/// @name Customizing Behavior
///---------------------------------------------------------------------------------------

@optional

/**
 *  Sent to the receiver just after the navigation controller displays a view controller’s view and navigation item properties.
 */
-(void)navigationController: (BFNavigationController *)navigationController didShowViewController: (NSViewController *)viewController animated: (BOOL)animated;

/**
 *  Sent to the receiver just before the navigation controller displays a view controller’s view and navigation item properties.
 */
-(void)navigationController: (BFNavigationController *)navigationController willShowViewController: (NSViewController *)viewController animated:(BOOL)animated;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface BFNavigationController : NSViewController

///---------------------------------------------------------------------------------------
/// @name Creating Navigation Controllers
///---------------------------------------------------------------------------------------

/**
 *  Initializes and returns a newly created navigation controller.
 */
-(id)initWithFrame: (NSRect)frame rootViewController: (NSViewController *)controller;

///---------------------------------------------------------------------------------------
/// @name Accessing Items on the Navigation Stack
///---------------------------------------------------------------------------------------

/**
 *  The view controller at the top of the navigation stack. (read-only)
 */
@property (nonatomic, readonly)NSViewController *topViewController;

/**
 *  The view controller associated with the currently visible view in the navigation interface. (read-only)
 */
@property (nonatomic, readonly)NSViewController *visibleViewController;

/**
 *  The view controllers currently on the navigation stack.
 */ 
@property (nonatomic, copy)NSArray *viewControllers;

/**
 *  Replaces the view controllers currently managed by the navigation controller with the specified items.
 */
-(void)setViewControllers: (NSArray *)viewControllers animated: (BOOL)animated;

///---------------------------------------------------------------------------------------
/// @name Pushing and Popping Stack Items
///---------------------------------------------------------------------------------------

/**
 *  Pushes a view controller onto the receiver’s stack and updates the display.
 */
-(void)pushViewController: (NSViewController *)viewController animated: (BOOL)animated;
-(void)pushViewController: (NSViewController *)viewController animated: (BOOL)animated completionHandler:(void (^)(void))completionHandler;
/**
 *  Pops the top view controller from the navigation stack and updates the display.
 */
-(NSViewController *)popViewControllerAnimated: (BOOL)animated;

/**
 *  Pops all the view controllers on the stack except the root view controller and updates the display.
 */
-(NSArray *)popToRootViewControllerAnimated: (BOOL)animated;

/**
 *  Pops view controllers until the specified view controller is at the top of the navigation stack.
 */
-(NSArray *)popToViewController: (NSViewController *)viewController animated: (BOOL)animated;

///---------------------------------------------------------------------------------------
/// @name Accessing the Delegate
///---------------------------------------------------------------------------------------

/**
 *  The reciever's delegate or nil.
 */
@property (nonatomic, assign)id<BFNavigationControllerDelegate> delegate;

@end
