//
//  Location.h
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

#import <Foundation/Foundation.h>

// Supported bounds around the city of Zurich.
#define BOUNDS_SOUTHWEST_LON 47.328392
#define BOUNDS_SOUTHWEST_LAT 8.464172
#define BOUNDS_NORTHEAST_LON 47.436693
#define BOUNDS_NORTHEAST_LAT 8.610260

/**
 * The Location class holds all information belonging to a location, such as
 * the from and to locations of a route.
 */
@interface Location : NSObject <NSCoding, NSCopying>

/**
 * Name of the location.
 */
@property (nonatomic, copy) NSString *name;

/**
 * Latitude of the location (WGS84 format).
 */
@property (nonatomic, strong) NSNumber *latitude;

/**
 * Longitude of the location (WGS84 format).
 */
@property (nonatomic, strong) NSNumber *longitude;

/**
 * Checks whether the given location is within the
 * bounds supported by the application (see DEFINES on top).
 *
 * @param location  Location to check.
 */
+ (BOOL)insideBounds:(Location *)location;

/**
 * Checks whether given location is valid location and
 * informs the user if there is a problem.
 *
 * @param location  Location to check.
 */
+ (void) checkLocation:(Location *)location;

@end