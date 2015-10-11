//
//  Location.m
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
#import "Location.h"

@implementation Location

// Check whether location is inside the supported bounds
+ (BOOL)insideBounds:(Location *)location {
    if ([location.latitude doubleValue] < BOUNDS_SOUTHWEST_LAT || [location.latitude doubleValue] > BOUNDS_NORTHEAST_LAT ||
        [location.longitude doubleValue] < BOUNDS_SOUTHWEST_LON || [location.longitude doubleValue] > BOUNDS_NORTHEAST_LON) {
        return FALSE;
    } else {
        return TRUE;
    }
}

// Check whether location is valid
+ (void) checkLocation:(Location *)location {
    // If address is NIL then we could not reach Google for geocoding.
    if (location.name == Nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Could not reach Google to get coordinates of specified location"
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    // If address is @"" then we could not find location entered by the user.
    else {
        if ([location.name length] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Could not find coordinates of specified location"
                                                           delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            // Check whether coordinates are within the supported region.
            if (![Location insideBounds:location]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Specified location is outside the supported area of Zurich, Switzerland"
                                                               delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        }
    }
}

#pragma mark NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.latitude forKey:@"latitude"];
    [encoder encodeObject:self.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = [decoder decodeObjectForKey:@"name"];
    self.latitude = [decoder decodeObjectForKey:@"latitude"];
    self.longitude = [decoder decodeObjectForKey:@"longitude"];
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    Location *location = [[Location alloc] init];
    location.name = [self.name copyWithZone:zone];
    location.latitude = [self.latitude copyWithZone:zone];
    location.longitude = [self.longitude copyWithZone:zone];
    
    return location;
}

@end
