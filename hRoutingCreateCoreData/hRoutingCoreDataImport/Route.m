//
//  Route.m
//  hRoutingCoreDataImport
//
//  Created by David Hasenfratz on 17/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
//
//  hRoutingCoreDataImport is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Foobar is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

#import "Route.h"

@implementation Route


#pragma mark NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.descr forKey:@"descr"];
    [encoder encodeObject:self.date forKey:@"date"];
    [encoder encodeObject:self.from forKey:@"from"];
    [encoder encodeObject:self.to forKey:@"to"];
    [encoder encodeObject:self.shortestPath forKey:@"shortestPath"];
    [encoder encodeObject:self.healthOptPath forKey:@"healthOptPath"];
    [encoder encodeObject:self.shortestPathDistance forKey:@"shortestPathDistance"];
    [encoder encodeObject:self.shortestPathPollution forKey:@"shortestPathPollution"];
    [encoder encodeObject:self.hOptPathDistance forKey:@"hOptPathDistance"];
    [encoder encodeObject:self.hOptPathPollution forKey:@"hOptPathPollution"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.descr = [decoder decodeObjectForKey:@"descr"];
    self.date = [decoder decodeObjectForKey:@"date"];
    self.from = [decoder decodeObjectForKey:@"from"];
    self.to = [decoder decodeObjectForKey:@"to"];
    self.shortestPath = [decoder decodeObjectForKey:@"shortestPath"];
    self.healthOptPath = [decoder decodeObjectForKey:@"healthOptPath"];
    self.shortestPathDistance = [decoder decodeObjectForKey:@"shortestPathDistance"];
    self.shortestPathPollution = [decoder decodeObjectForKey:@"shortestPathPollution"];
    self.hOptPathDistance = [decoder decodeObjectForKey:@"hOptPathDistance"];
    self.hOptPathPollution = [decoder decodeObjectForKey:@"hOptPathPollution"];
    
    return self;
}

+ (void) copyComputedRoutesFrom:(Route *)origRoute to:(Route*)destRoute {
    
    destRoute.shortestPath = [origRoute.shortestPath copy];
    destRoute.healthOptPath = [origRoute.healthOptPath copy];
    destRoute.shortestPathDistance = [origRoute.shortestPathDistance copy];
    destRoute.shortestPathPollution = [origRoute.shortestPathPollution copy];
    destRoute.hOptPathDistance = [origRoute.hOptPathDistance copy];
    destRoute.hOptPathPollution = [origRoute.hOptPathPollution copy];

}

@end
