//
//  Location.h
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

#import <Foundation/Foundation.h>

// Supported bounds around the city of Zurich
// These bounds are updated with more exact coordinates when loading data
#define BOUNDS_SOUTHWEST_LON 47.328392
#define BOUNDS_SOUTHWEST_LAT 8.464172
#define BOUNDS_NORTHEAST_LON 47.436693
#define BOUNDS_NORTHEAST_LAT 8.610260

@interface Location : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

+ (BOOL)insideBounds:(Location *)location;

@end
