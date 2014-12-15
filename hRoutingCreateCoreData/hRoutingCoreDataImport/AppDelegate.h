//
//  AppDelegate.h
//  hRoutingCoreDataImport
//
//  Created by David Hasenfratz on 28/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
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

