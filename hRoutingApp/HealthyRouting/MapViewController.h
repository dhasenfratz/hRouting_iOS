//
//  MapViewController.h
//  HealthyRouting
//
//  Created by David Hasenfratz on 20/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"
#import "Route.h"
#import "AppDelegate.h"

@interface MapViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationAuthorizationManager;
@property (nonatomic, strong) Route *route;
- (IBAction)InfoTouchAction:(id)sender;

@property (nonatomic, weak) AppDelegate *appDelegate;

@end
