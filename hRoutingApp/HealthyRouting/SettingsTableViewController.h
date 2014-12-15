//
//  SettingsTableViewController.h
//  HealthyRouting
//
//  Created by David Hasenfratz on 22/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *histSizeTextField;
- (IBAction)histSizeEditEndAction:(id)sender;
- (IBAction)checkForUpdateAction:(id)sender;
- (IBAction)clearHistoryAction:(id)sender;

@property (weak, nonatomic) AppDelegate *appDelegate;

extern const AppDelegate *app;

@end
