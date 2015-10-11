//
//  MyRouteTableViewController.m
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

#import "MyRouteTableViewController.h"

@interface MyRouteTableViewController ()

@end

@implementation MyRouteTableViewController

@synthesize fromTextField, toTextField;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Use transparent background color
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
  
    // Set route choice switches
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.shortestRouteSwitch setOn:self.appDelegate.shortestRoute];
    [self.healthOptimalRouteSwitch setOn:self.appDelegate.hOptimalRoute];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

// If user ends editing from text field then try to geocode the given location.
- (IBAction)fromEditEndAction:(id)sender {
    
    if (self.from == Nil) {
        self.from = [[Location alloc] init];
    }
    
    if ([self.fromTextField.text length] == 0) {
        self.from.name = @"";
        self.from.longitude = Nil;
        self.from.latitude = Nil;
        return;
    }
    
    if ([self.fromTextField.text isEqualToString:@"Getting location..."]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Get geocode of address
        [MyRouteTableViewController getGeoCode:fromTextField.text loc:self.from];

        dispatch_async(dispatch_get_main_queue(), ^{
            [Location checkLocation:self.from];
            if ([self.from.name length] != 0) {
                self.fromTextField.text = self.from.name;
            } else {
                self.fromTextField.text = @"";
            }
        });
        
    });
}

- (IBAction)toEditEndAction:(id)sender {
    
    if (self.to == Nil) {
        self.to = [[Location alloc] init];
    }
    
    if ([self.toTextField.text length] == 0) {
        self.to.name = @"";
        self.to.longitude = Nil;
        self.to.latitude = Nil;
        return;
    }
    
    if ([self.toTextField.text isEqualToString:@"Getting location..."]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        // Get geocode of address
        [MyRouteTableViewController getGeoCode:toTextField.text loc:self.to];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [Location checkLocation:self.to];
            if ([self.to.name length] != 0) {
                self.toTextField.text = self.to.name;
            }
            else {
                self.toTextField.text = @"";
            }
        });
    });
}

- (IBAction)shortestRouteAction:(id)sender {
    BOOL routeSwitch = self.shortestRouteSwitch.isOn;
    
    self.appDelegate.shortestRoute = routeSwitch;
    
    // Store new setting as user default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:routeSwitch forKey:@"shortestRoute"];
    [defaults synchronize];
}

- (IBAction)hOptimalRouteAction:(id)sender {
    BOOL routeSwitch = self.healthOptimalRouteSwitch.isOn;
    
    self.appDelegate.hOptimalRoute = routeSwitch;
    
    // Store new setting as user default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:routeSwitch forKey:@"hOptRoute"];
    [defaults synchronize];
}

- (IBAction)myLocationFromAction:(id)sender {
    
    BOOL res = [self enableMyLocation];
    if (!res) {
        return;
    }
    
    self.fromTextField.text = @"Getting location...";
    
    if (self.from == Nil) {
        self.from = [[Location alloc] init];
    }
    self.from.name = @"Getting location...";
    self.from.latitude = Nil;
    self.from.longitude = Nil;
}

- (IBAction)myLocationToAction:(id)sender {
    
    BOOL res = [self enableMyLocation];
    if (!res) {
        return;
    }
    
    self.toTextField.text = @"Getting location...";
    
    if (self.to == Nil) {
        self.to = [[Location alloc] init];
    }
    self.to.name = @"Getting location...";
    self.to.latitude = Nil;
    self.to.longitude = Nil;
    
}

+ (void) getGeoCode:(NSString *)inputAddress loc:(Location *)location {
    
    NSString *geocodingBaseUrl = @"https://maps.googleapis.com/maps/api/geocode/json?";
    // Use bounds for Zurich in the geocode requrest to bias geocoding for the Zurich area
    NSString *url = [NSString stringWithFormat:@"%@address=%@&sensor=false&language=de&bounds=%f,%f|%f,%f", geocodingBaseUrl, inputAddress, BOUNDS_SOUTHWEST_LAT, BOUNDS_SOUTHWEST_LON, BOUNDS_NORTHEAST_LAT, BOUNDS_NORTHEAST_LON];
    url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURL *queryUrl = [NSURL URLWithString:url];
    
    NSData *data = [NSData dataWithContentsOfURL: queryUrl];
    
    if (data != Nil) {
        [MyRouteTableViewController fetchedData:data loc:location];
    }
    
    return;
}

+ (void) fetchedData:(NSData *)data loc:(Location *)location {
    
    NSError* error;
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    NSArray* results = [json objectForKey:@"results"];
    if ([results count] == 0) {
        location.name = @"";
        return;
    }
    
    // If we received multiple results prefer first one, which is inside the supported bounds
    NSString *address;
    NSDictionary *geometry, *loc;
    NSString *lat, *lon;

    for (NSDictionary *result in results) {
        address = [result objectForKey:@"formatted_address"];
        geometry = [result objectForKey:@"geometry"];
        loc = [geometry objectForKey:@"location"];
        lat = [loc objectForKey:@"lat"];
        lon = [loc objectForKey:@"lng"];
        
        location.latitude = @([lat floatValue]);
        location.longitude = @([lon floatValue]);
        location.name = address;
        
        if ([Location insideBounds:location]) {
            return;
        }
    }
    
    // If none inside bounds, use first result
    NSDictionary *result = [results objectAtIndex:0];
    address = [result objectForKey:@"formatted_address"];
    geometry = [result objectForKey:@"geometry"];
    loc = [geometry objectForKey:@"location"];
    lat = [loc objectForKey:@"lat"];
    lon = [loc objectForKey:@"lng"];
    
    location.latitude = @([lat floatValue]);
    location.longitude = @([lon floatValue]);
    location.name = address;
    
    return;
}

+ (void) getReverseGeoCode:(Location *)location {
    
    NSString *geocodingBaseUrl = @"https://maps.googleapis.com/maps/api/geocode/json?";
    // Use bounds for Zurich in the geocode requrest to bias geocoding for the Zurich area
    NSString *url = [NSString stringWithFormat:@"%@latlng=%@,%@&sensor=false&language=de", geocodingBaseUrl, location.latitude.stringValue, location.longitude.stringValue];
    url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURL *queryUrl = [NSURL URLWithString:url];
    
    NSData *data = [NSData dataWithContentsOfURL: queryUrl];
    
    if (data != Nil) {
        [MyRouteTableViewController fetchedData:data loc:location];
    }
    
    return;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    
    if (location.horizontalAccuracy <= 100) {
        [self.locationAuthorizationManager stopUpdatingLocation];
        
        // Perform reverse geo coding
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if ([self.fromTextField.text isEqualToString:@"Getting location..."]) {
                self.from.latitude = [NSNumber numberWithFloat:location.coordinate.latitude];
                self.from.longitude = [NSNumber numberWithFloat:location.coordinate.longitude];
                NSLog(@"Get from location for %f, %f",location.coordinate.latitude,location.coordinate.longitude);
                // Get address of location
                [MyRouteTableViewController getReverseGeoCode:self.from];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([self.fromTextField.text isEqualToString:@"Getting location..."]) {
                    [NSThread sleepForTimeInterval:0.2];
                    if ([self.from.name length] != 0) {
                        self.fromTextField.text = self.from.name;
                    } else {
                        self.fromTextField.text = @"";
                    }
                    NSLog(@"From location updated: %@",self.fromTextField.text);
                    [Location checkLocation:self.from];
                }
            });
        });
        
        // Perform reverse geo coding
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if ([self.toTextField.text isEqualToString:@"Getting location..."]) {
                self.to.latitude = [NSNumber numberWithFloat:location.coordinate.latitude];
                self.to.longitude = [NSNumber numberWithFloat:location.coordinate.longitude];
                NSLog(@"Get to location for %f, %f",location.coordinate.latitude,location.coordinate.longitude);
                // Get address of location
                [MyRouteTableViewController getReverseGeoCode:self.to];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.toTextField.text isEqualToString:@"Getting location..."]) {
                    [NSThread sleepForTimeInterval:0.2];
                    if ([self.to.name length] != 0) {
                        self.toTextField.text = self.to.name;
                    }
                    else {
                        self.toTextField.text = @"";
                    }
                    NSLog(@"To location updated: %@",self.toTextField.text);
                    [Location checkLocation:self.to];
                }
            });
        });
    }
    
    NSLog(@"Coordinate: %f, %f with accuracy of %f m",location.coordinate.latitude, location.coordinate.longitude,location.horizontalAccuracy);
}

// Resolve my location
- (void)resolveMyLocation
{
    NSLog(@"Resolve location");
    
    self.locationAuthorizationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationAuthorizationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [self.locationAuthorizationManager startUpdatingLocation];
}

// Request authorization if required
- (BOOL)enableMyLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        NSLog(@"Authorization not granted");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location access denied" message:@"Go to settings and allow location access for hRouting"
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return FALSE;
        
    } else {
        NSLog(@"Request authorization");
        [self requestLocationAuthorization];
        return TRUE;
    }
}

// Ask the CLLocationManager for location authorization,
// and be sure to retain the manager somewhere on the class
- (void)requestLocationAuthorization
{
    self.locationAuthorizationManager = [[CLLocationManager alloc] init];
    self.locationAuthorizationManager.delegate = self;
    
    //[self.locationAuthorizationManager requestWhenInUseAuthorization];
    // The request call only exists for >= ios8.0
    if ([self.locationAuthorizationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationAuthorizationManager requestWhenInUseAuthorization];
    } else {
        [self resolveMyLocation];
    }
}

// Handle the authorization callback, this is usually called on a background thread so go back to main
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusRestricted) {
        NSLog(@"Authorization granted");
        [self performSelectorOnMainThread:@selector(resolveMyLocation) withObject:nil waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Headet text color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor grayColor];
    header.textLabel.font = [UIFont systemFontOfSize:15.0];
    // Header background color
    header.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
}

@end
