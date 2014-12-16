//
//  MyRouteViewController.h
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
//  hRouting is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with hRouting.  If not, see <http://www.gnu.org/licenses/>.
//

#import <UIKit/UIKit.h>
#import "MyRouteTableViewController.h"
#import "AppDelegate.h"

// Different shortest route algorithms exist:
// - 1: Dijkstra
// - 2: A*
#define SHORTEST_ROUTE_ALG 1
// Run tests to find average computation times.
#define ENABLE_TIMING_TEST 0
// Run tests to compare Dijkstra and A*.
#define ENABLE_ALG_TEST 0
// Number of test runs.
#define TEST_RUNS 1000

/**
 * The MyRouteViewController class is responsible for the MyRoute navigation tab.
 * The tab is used to let the user input the from and to location and let the user
 * choose what kind of route it wants to compute.
 */
@interface MyRouteViewController : UIViewController

/**
 * Points to the unique appDelegate of the app.
 */
@property (weak, nonatomic) AppDelegate *appDelegate;

/**
 * Spinner is active when data is initially loaded and while new routes
 * are computed.
 */
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

/**
 * The child view managing the from and to input fields and route selection switches.
 */
@property (nonatomic, weak) MyRouteTableViewController *childViewController;

/**
 * The container view inside the MyRoute tab holding the child view.
 */
@property (weak, nonatomic) IBOutlet UIView *containerView;

/**
 * Button to compute shorted and health-optimal routes for the given locations.
 */
@property (weak, nonatomic) IBOutlet UIButton *computeRouteButton;

/**
 * Called when user taps into the MyRoute tab. If active, the keyboard view
 * is resigned.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)tapParentViewController:(id)sender;

/**
 * Called when the Compute Route button is pressed. The method computes
 * the shortest and health-optimal routes and segues to the map view to
 * display the routes on top of Google Maps.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)computeRouteAction:(id)sender;

@end