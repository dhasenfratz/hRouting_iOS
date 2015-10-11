//
//  MyRouteTableViewController.h
//  hRouting
//
//  Created by David Hasenfratz on 19/09/14.
//  Copyright (c) 2015 David Hasenfratz. All rights reserved.
//
//  hRouting is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  hRouting is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with hRouting.  If not, see <http://www.gnu.org/licenses/>.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"
#import "AppDelegate.h"

/**
 * The MyRouteTableViewController class is responsible for the child view
 * inside the MyRoute navigation tab. The class handles the from and to
 * location input fields and the route switch buttons.
 */
@interface MyRouteTableViewController : UITableViewController <CLLocationManagerDelegate>

/**
 * Points to the unique appDelegate of the app.
 */
@property (nonatomic, weak) AppDelegate *appDelegate;

/**
 * The from location entered by the user storing name and coordinates.
 */
@property (nonatomic, strong) Location *from;

/**
 * The to location entered by the user storing name and coordinates.
 */
@property (nonatomic, strong) Location *to;

/**
 * The from location text field.
 */
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;

/**
 * The to location text field.
 */
@property (weak, nonatomic) IBOutlet UITextField *toTextField;

/**
 * Switch to select whether the shortest route is computed.
 */
@property (weak, nonatomic) IBOutlet UISwitch *shortestRouteSwitch;

/**
 * Switch to select whether the health-optimal route is computed.
 */
@property (weak, nonatomic) IBOutlet UISwitch *healthOptimalRouteSwitch;

/**
 * The location authorization manager to request the user's location.
 * This enables the automatic detection of the user's location, which can
 * be set as from or to location.
 */
@property (nonatomic, strong) CLLocationManager *locationAuthorizationManager;

/**
 * Called when the user ends editing the from text field. The method checks whether the
 * given location is valid and uses the Google Geocoding API to get the location's coordinates.
 * Further, it checks whether the coordinates are within the bounds supported by the app.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)fromEditEndAction:(id)sender;

/**
 * Called when the user ends editing the to text field. The method checks whether the
 * given location is valid and uses the Google Geocoding API to get the location's coordinates.
 * Further, it checks whether the coordinates are within the bounds supported by the app.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)toEditEndAction:(id)sender;

/**
 * Called when the user changes the shortest route switch. The method updates the
 * default user setting with the new value.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)shortestRouteAction:(id)sender;

/**
 * Called when the user changes the health-optimal route switch. The method updates the
 * default user setting with the new value.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)hOptimalRouteAction:(id)sender;

/**
 * Called when the user wants to retrieve its location for the from location. The method
 * gets the user's coordinates, checks whether it is inside the bounds supported by the app,
 * and uses the Google Geocoding API to get the name of the location.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)myLocationFromAction:(id)sender;

/**
 * Called when the user wants to retrieve its location for the to location. The method
 * gets the user's coordinates, checks whether it is inside the bounds supported by the app,
 * and uses the Google Geocoding API to get the name of the location.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)myLocationToAction:(id)sender;

@end
