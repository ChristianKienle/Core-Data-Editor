//
//  CDEMasterViewController.h
//  iOS Example
//
//  Created by cmk on 8/9/13.
//  Copyright (c) 2013 Thermal Core. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface CDEMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
