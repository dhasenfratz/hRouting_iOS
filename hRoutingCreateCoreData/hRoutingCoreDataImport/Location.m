//
//  Location.m
//  hRoutingCoreDataImport
//
//  Created by David Hasenfratz on 19/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
//
//  hRoutingCoreDataImport is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  hRoutingCoreDataImport is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with hRoutingCoreDataImport.  If not, see <http://www.gnu.org/licenses/>.
//

#import "Location.h"

@implementation Location

// Check whether location is inside the supported bounds
+ (BOOL)insideBounds:(Location *)location {
    if ([location.latitude doubleValue] < BOUNDS_SOUTHWEST_LON || [location.latitude doubleValue] > BOUNDS_NORTHEAST_LON ||
        [location.longitude doubleValue] < BOUNDS_SOUTHWEST_LAT || [location.longitude doubleValue] > BOUNDS_NORTHEAST_LAT) {
        return FALSE;
    } else {
        return TRUE;
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
