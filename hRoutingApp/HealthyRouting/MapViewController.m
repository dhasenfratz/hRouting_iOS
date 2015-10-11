//
//  MapViewController.m
//  hRouting
//
//  Created by David Hasenfratz on 20/09/14.
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

#import <GoogleMaps/GoogleMaps.h>
#import "MapViewController.h"

@interface MapViewController () {
    GMSMapView *mapView;
}

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Set as title of the navigation bar the route description
    self.navigationItem.title = self.route.descr;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Set camera position between origin and destination.
    mapView = [[GMSMapView alloc] init];
    mapView.settings.compassButton = TRUE;
    mapView.settings.myLocationButton = TRUE;
    mapView.accessibilityElementsHidden = NO;
    self.view = mapView;
    
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver >= 8.0) {
        [self enableMyLocation];
    }
    
    // Create markers for origin and destination
    GMSMarker *markerFrom = [[GMSMarker alloc] init];
    markerFrom.position = CLLocationCoordinate2DMake([self.route.from.latitude doubleValue], [self.route.from.longitude doubleValue]);
    markerFrom.snippet = self.route.from.name;
    markerFrom.map = mapView;
    
    GMSMarker *markerTo = [[GMSMarker alloc] init];
    markerTo.position = CLLocationCoordinate2DMake([self.route.to.latitude doubleValue], [self.route.to.longitude doubleValue]);
    markerTo.snippet = self.route.to.name;
    markerTo.map = mapView;
    
    // Draw shortest path
    if (self.appDelegate.shortestRoute) {
        GMSMutablePath *shortestPath = [GMSMutablePath path];
        for (NSNumber *nodeId in self.route.shortestPath) {
            [shortestPath addLatitude:self.appDelegate.nodeLatitude[[nodeId integerValue]] longitude:self.appDelegate.nodeLongitude[[nodeId integerValue]]];
        }
        GMSPolyline *polylineShPath = [GMSPolyline polylineWithPath:shortestPath];
        polylineShPath.strokeColor = [UIColor colorWithRed:0.89 green:0.29 blue:0.2 alpha:1.0];
        polylineShPath.strokeWidth = 6.0f;
        polylineShPath.title = @"Shortest route";
        polylineShPath.tappable = TRUE;
        polylineShPath.map = mapView;
    }
    
    // Draw health-optimal path
    if (self.appDelegate.hOptimalRoute) {
        
        NSMutableArray *allhealthOptPaths = [[NSMutableArray alloc] init];
        GMSMutablePath *healthOptPath = [GMSMutablePath path];
        [allhealthOptPaths addObject:healthOptPath];
        NSNumber *lastNode;
        BOOL sameRoute = FALSE;
        for (NSNumber *nodeId in self.route.healthOptPath) {
            // Check whether this nodeId is part of the health-optimal path
            if (lastNode != Nil && (([self.route.shortestPath containsObject:nodeId] && !sameRoute) ||
                (![self.route.shortestPath containsObject:nodeId] && sameRoute))) {
                sameRoute = !sameRoute;
                [healthOptPath addLatitude:self.appDelegate.nodeLatitude[[nodeId integerValue]] longitude:self.appDelegate.nodeLongitude[[nodeId integerValue]]];
                healthOptPath = [GMSMutablePath path];
                [allhealthOptPaths addObject:healthOptPath];
                [healthOptPath addLatitude:self.appDelegate.nodeLatitude[[lastNode integerValue]] longitude:self.appDelegate.nodeLongitude[[lastNode integerValue]]];
            }
            
            [healthOptPath addLatitude:self.appDelegate.nodeLatitude[[nodeId integerValue]] longitude:self.appDelegate.nodeLongitude[[nodeId integerValue]]];
            lastNode = nodeId;
        }
        // Draw overlapping route part with smaller stroke width
        float currStr = 6.0f;
        for (GMSMutablePath *p in allhealthOptPaths) {
            GMSPolyline *polylineHePath = [GMSPolyline polylineWithPath:p];
            polylineHePath.strokeColor = [UIColor colorWithRed:0 green:0.8 blue:0.8 alpha:1.0];
            polylineHePath.strokeWidth = currStr;
            polylineHePath.title = @"Health-optimal route";
            polylineHePath.tappable = TRUE;
            polylineHePath.map = mapView;
            currStr = currStr==6.0f?2.0f:6.0f;
        }
    }
    
    // Automatically zoom to the displayed routes (with some padding)
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:markerFrom.position coordinate:markerTo.position];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:100];
    [mapView moveCamera:update];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)InfoTouchAction:(id)sender {
    // Show info box with details to the computed routes
    
    UIAlertView *alert;
    if (self.route.shortestPathDistance == Nil || self.route.hOptPathDistance == Nil) {
        alert = [[UIAlertView alloc] initWithTitle:@"Route Information" message:@"\nRed:\nShortest route\n\nGreen:\nHealth-optimal route\n\nEnable the computation of both routes to allow comparing them"
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    } else {
        
        NSString *ms;
        // Do not divide by zero
        if ([self.route.shortestPathPollution floatValue] == 0) {
            ms = [NSString stringWithFormat:@"\nShortest route (red):\n%.1fkm long\n\nHealth-optimal route (green):\n%ldm longer distance\n%.1f%% less air pollution exposure",[self.route.shortestPathDistance floatValue]/1000.0f,[self.route.hOptPathDistance longValue]-[self.route.shortestPathDistance longValue],([self.route.shortestPathPollution floatValue]-[self.route.hOptPathPollution floatValue])];
        } else {
            ms = [NSString stringWithFormat:@"\nShortest route (red):\n%.1fkm long\n\nHealth-optimal route (green):\n%ldm longer distance\n%.1f%% less air pollution exposure",[self.route.shortestPathDistance floatValue]/1000.0f,[self.route.hOptPathDistance longValue]-[self.route.shortestPathDistance longValue],([self.route.shortestPathPollution floatValue]-[self.route.hOptPathPollution floatValue])/[self.route.shortestPathPollution floatValue]*100.0f];
        }
        alert = [[UIAlertView alloc] initWithTitle:@"Route Information" message:ms
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    }
    [alert show];
}

- (void)enableMyLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined)
        [self requestLocationAuthorization];
    else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
        return; // we are not allowed to show the user's location so do not enable location service
    else
        [(GMSMapView *)(self.view) setMyLocationEnabled:TRUE];
}

// Ask the CLLocationManager for location authorization
- (void)requestLocationAuthorization
{
    self.locationAuthorizationManager = [[CLLocationManager alloc] init];
    self.locationAuthorizationManager.delegate = self;
    
    [self.locationAuthorizationManager requestWhenInUseAuthorization];
}

// Handle the location authorization callback
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined) {
        [self performSelectorOnMainThread:@selector(enableMyLocation) withObject:nil waitUntilDone:[NSThread isMainThread]];
        
        self.locationAuthorizationManager.delegate = nil;
        self.locationAuthorizationManager = nil;
    }
}

@end
