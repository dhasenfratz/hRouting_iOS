//
//  AppDelegate.h
//  HealthyRouting
//
//  Created by David Hasenfratz on 17/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>

// Google API key for hRouting (REPLACE WITH OWN KEY!)
#define GOOGLE_MAPS_API_KEY @"xxxx"

#define DEFAULT_HIST_SIZE 20
#define DEFAULT_SWITCH TRUE

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSMutableArray *historyEntries;
@property (nonatomic, strong) NSNumber *histSize;
@property BOOL shortestRoute;
@property BOOL hOptimalRoute;
@property BOOL firstRun;
@property (nonatomic, strong) NSMutableArray *graph;

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

// Core data stuff
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSArray *)getCoreData:(NSString *)entityName withContext:(NSManagedObjectContext *)context;

@end
