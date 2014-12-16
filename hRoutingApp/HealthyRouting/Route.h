//
//  Route.h
//  hRouting
//
//  Created by David Hasenfratz on 17/09/14.
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
#import "Location.h"

/**
 * The Route class holds all information belonging to a route, such as from and to
 * destinations, date of search, and the shortest and health-ooptimal routes.
 */
@interface Route : NSObject <NSCoding>

/**
 * From and to location of the route.
 */
@property (nonatomic, copy) NSString *descr;

/**
 * Date of computing the route.
 */
@property (nonatomic, strong) NSDate *date;

/**
 * From location of the route.
 */
@property (nonatomic, strong) Location *from;

/**
 * To location of the route.
 */
@property (nonatomic, strong) Location *to;

/**
 * Array of node ids belonging to the shortest route between
 * the from and to locations.
 */
@property (nonatomic, strong) NSMutableArray *shortestPath;

/**
 * Array of node ids belonging to the shortest route between
 * the from and to locations.
 */
@property (nonatomic, strong) NSMutableArray *healthOptPath;

/**
 * Lenght of the shortest route.
 */
@property (nonatomic, strong) NSNumber *shortestPathDistance;

/**
 * Pollution exposure of the shortest route.
 */
@property (nonatomic, strong) NSNumber *shortestPathPollution;

/**
 * Lenght of the health-optimal route.
 */
@property (nonatomic, strong) NSNumber *hOptPathDistance;

/**
 * Pollution exposure of the health-optimal route.
 */
@property (nonatomic, strong) NSNumber *hOptPathPollution;

/**
 * Copies all fields related to the shortest and health-optimal routes
 * to the new route object.
 *
 * @param orig  Original route to copy from.
 * @param dest  Destination route to copy to.
 */
+ (void) copyComputedRoutesOrig:(Route *)orig dest:(Route*)dest;

@end
