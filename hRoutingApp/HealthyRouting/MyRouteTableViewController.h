//
//  MyRouteTableViewController.h
//  HealthyRouting
//
//  Created by David Hasenfratz on 19/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"
#import "AppDelegate.h"

@interface MyRouteTableViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) Location *from;
@property (nonatomic, strong) Location *to;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (weak, nonatomic) IBOutlet UISwitch *shortestRouteSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *healthOptimalRouteSwitch;
- (IBAction)fromEditEndAction:(id)sender;
- (IBAction)toEditEndAction:(id)sender;
- (IBAction)shortestRouteAction:(id)sender;
- (IBAction)hOptimalRouteAction:(id)sender;
- (IBAction)myLocationFromAction:(id)sender;
- (IBAction)myLocationToAction:(id)sender;

@property (nonatomic, strong) CLLocationManager *locationAuthorizationManager;
@property (nonatomic, weak) AppDelegate *appDelegate;

@end
