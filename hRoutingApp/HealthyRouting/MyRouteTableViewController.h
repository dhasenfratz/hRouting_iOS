//
//  MyRouteTableViewController.h
//  hRouting
//
//  Created by David Hasenfratz on 19/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
//
//  hRouting is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Foobar is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
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
