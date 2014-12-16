//
//  AppDelegate.h
//  hRoutingCoreDataImport
//
//  Created by David Hasenfratz on 28/09/14.
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

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Streetnetwork graph
@property double *nodeLatitude;
@property double *nodeLongitude;
@property long *nodeIndexFrom;
@property long *nodeIndexTo;
@property long *nodeEdgeTo;
@property long *edgeCostDist;
@property long *edgeCostHealth;
@property const unsigned long numNodes;
@property const unsigned long numEdges;

typedef struct {
    long nodeId;
    long dist;
    
} DistToSource;

@end

