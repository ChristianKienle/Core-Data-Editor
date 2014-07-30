//
//  CDEAppDelegate.h
//  iOS Example
//
//  Created by cmk on 8/9/13.
//  Copyright (c) 2013 Thermal Core. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
