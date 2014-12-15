//
//  Route.h
//  HealthyRouting
//
//  Created by David Hasenfratz on 17/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Route : NSObject <NSCoding>

@property (nonatomic, copy) NSString *descr;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) Location *from;
@property (nonatomic, strong) Location *to;
@property (nonatomic, strong) NSMutableArray *shortestPath;
@property (nonatomic, strong) NSMutableArray *healthOptPath;

@property (nonatomic, strong) NSNumber *shortestPathDistance;
@property (nonatomic, strong) NSNumber *shortestPathPollution;
@property (nonatomic, strong) NSNumber *hOptPathDistance;
@property (nonatomic, strong) NSNumber *hOptPathPollution;

+ (void) copyComputedRoutesFrom:(Route *)origRoute to:(Route*)destRoute;

@end
