//
//  Location.h
//  HealthyRouting
//
//  Created by David Hasenfratz on 19/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
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
+ (void) checkLocation:(Location *)location;

@end
