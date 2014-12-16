//
//  AppDelegate.h
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

#import <UIKit/UIKit.h>

// Google API key for hRouting (REPLACE WITH OWN KEY!).
#define GOOGLE_MAPS_API_KEY @"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

// Maximum size of the history (default value).
#define DEFAULT_HIST_SIZE 20
// Default position of the route option switches.
#define DEFAULT_SWITCH TRUE

/**
 * The AppDelegate class of the app. This is the first class, which
 * is initiated when the app is loaded.
 */
@interface AppDelegate : UIResponder <UIApplicationDelegate>

/**
 * History array holds all previous routes computed by the user. Initially it
 * is loaded with some exemplary routes.
 */
@property (nonatomic, strong) NSMutableArray *historyEntries;

/**
 * The maximum number of entries in the history array.
 */
@property (nonatomic, strong) NSNumber *histSize;

/**
 * Holds the switch position indicating whether the shortest route
 * should be computed.
 */
@property BOOL shortestRoute;

/**
 * Holds the switch position indicating whether the health-optimal route
 * should be computed.
 */
@property BOOL hOptimalRoute;

/**
 * Indicates whether the app is opened the first time. If yes,
 * the app will display a welcome message.
 */
@property BOOL firstRun;

/**
 * Part of the street network graph.
 * Array of latitude coordinates of all nodes in the street
 * network graph (is loaded from core data). Array index corresponds
 * to the node ID.
 *
 * For example:
 * nodeLatitude[42] holds the latitude of the node with ID 42.
 */
@property double *nodeLatitude;

/**
 * Part of the street network graph.
 * Array of longitude coordinates of all nodes in the street
 * network graph (is loaded from core data). Array index corresponds
 * to the node ID.
 *
 * For example:
 * nodeLatitude[42] holds the longitude of the node with ID 42.
 */
@property double *nodeLongitude;

/**
 * Part of the street network graph.
 * Array for all nodes in the street network graph indicating the first
 * index position in nodeEdgeTo, which belongs to the node ID of
 * the respective index in this array (is loaded from core data).
 *
 * For example:
 * nodeIndexFrom[42] holds the first index position where information
 * about the edges belonging to the node with ID 42 is stored in nodeEdgeTo.
 */
@property long *nodeIndexFrom;

/**
 * Part of the street network graph.
 * Array for all nodes in the street network graph indicating the last
 * index position in nodeEdgeTo, which belongs to the node ID of
 * the respective index in this array (is loaded from core data).
 *
 * For example:
 * nodeIndexTo[42] holds the last index position where information
 * about the edges belonging to the node with ID 42 is stored in nodeEdgeTo.
 */
@property long *nodeIndexTo;

/**
 * Part of the street network graph.
 * The array represents all edges in in the street network graph
 * (is loaded from core data). An edge at a given index is a link between
 * the node ID found in the range nodeIndexFrom and nodeIndexTo and the
 * node ID stored in the array.
 *
 * For example:
 * Assume nodeIndexFrom[42] = 100 and nodeIndexTo[42] = 105
 * Hence nodeEdgeTo[101] = 45 represents an edge going from node with ID 42 to
 * the node with ID 45.
 */
@property long *nodeEdgeTo;

/**
 * Part of the street network graph.
 * The array stores the distance cost of each edge in nodeEdgeTo 
 * (is loaded from core data).
 */
@property long *edgeCostDist;

/**
 * Part of the street network graph.
 * The array stores the pollution exposure cost of each edge
 * in nodeEdgeTo (is loaded from core data).
 */
@property long *edgeCostHealth;

/**
 * Part of the street network graph.
 * Number of nodes in the street network graph (is loaded from core data).
 */
@property const unsigned long numNodes;

/**
 * Part of the street network graph.
 * Number of edges in the street network graph (is loaded from core data).
 */
@property const unsigned long numEdges;

/**
 * Core data funtionality.
 * Object of the core data context.
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/**
 * Core data funtionality.
 * Object of the core data model.
 */
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

/**
 * Core data funtionality.
 * Object of the core data store coordinator.
 */
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 * Core data funtionality.
 * The method is called to persistently save the context in core data.
 */
- (void)saveContext;

/**
  * The method retrieves the URL to the application's document directory.
  *
  * @return URL to the application's document directory.
 */
- (NSURL *)applicationDocumentsDirectory;

/**
 * The method gets all data with the given entity name stored in the
 * application's core data.
 *
 * @param entityName  Name of the entity to retrieve (as defined in the data model).
 * @param context     The context of the core data.
 *
 * @return All data corresponding of the given entity.
 */
- (NSArray *)getCoreData:(NSString *)entityName withContext:(NSManagedObjectContext *)context;

@end
