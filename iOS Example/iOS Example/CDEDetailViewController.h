//
//  CDEDetailViewController.h
//  iOS Example
//
//  Created by cmk on 8/9/13.
//  Copyright (c) 2013 Thermal Core. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDEDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
