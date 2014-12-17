//
//  MapViewController.h
//  hRouting
//
//  Created by David Hasenfratz on 20/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
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
#import "Route.h"
#import "AppDelegate.h"

/**
 * The MapViewController class is responsible for the map view, which shows
 * the computed routes on top of Google Maps. This view is either reached from
 * the MyRoute tab after computing new routes or from the History tab when
 * looking at a route computed previously.
 */
@interface MapViewController : UIViewController <CLLocationManagerDelegate>

/**
 * Points to the unique appDelegate of the app.
 */
@property (nonatomic, weak) AppDelegate *appDelegate;

/**
 * The location authorization manager to request the user's location.
 * This enables to show the user's current location on Google Maps.
 */
@property (nonatomic, strong) CLLocationManager *locationAuthorizationManager;

/**
 * Route holds shortest and health-optimal route information, which are
 * displayed on top of Google Maps.
 */
@property (nonatomic, strong) Route *route;

/**
 * Called when the Info button is pressed. The method compares the length
 * and pollution exposure of the shortest and health-optimal routes and
 * displays this information to the user.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)InfoTouchAction:(id)sender;

@end
