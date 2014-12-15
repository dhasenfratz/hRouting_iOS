//
//  MyRouteViewController.h
//  HealthyRouting
//
//  Created by David Hasenfratz on 19/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRouteTableViewController.h"
#import "AppDelegate.h"

// Different shortest route algorithms exist:
// - 1: Dijkstra
// - 2: A*
#define SHORTEST_ROUTE_ALG 1
// Run tests to find average computation times
#define ENABLE_TIMING_TEST 0
// Run tests to compare Dijkstra and A*
#define ENABLE_ALG_TEST 0
// Number of test runs
#define TEST_RUNS 1000

@interface MyRouteViewController : UIViewController

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, weak) MyRouteTableViewController *childViewController;
- (IBAction)tapParentViewController:(id)sender;
- (IBAction)computeRouteAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *computeRouteButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) AppDelegate *appDelegate;

typedef struct {
    long nodeId;
    double dist;
} DistToSource;

@end
