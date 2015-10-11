//
//  AppDelegate.m
//  hRoutingCoreDataImport
//
//  Created by David Hasenfratz on 28/09/14.
//  Copyright (c) 2015 David Hasenfratz. All rights reserved.
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

#import "AppDelegate.h"
#import "Route.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
- (IBAction)saveAction:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // Load csv files
    
    NSError *err = nil;
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"GraphNodesCoordinates" ofType:@"csv"];
    NSString *data = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&err];
    NSMutableArray *nodesCoordinates = [[data componentsSeparatedByString: @"\n"] mutableCopy];
    [nodesCoordinates removeObjectAtIndex:0];
    NSLog(@"Imported coordinates of %lu nodes",(unsigned long)[nodesCoordinates count]);
    
    dataPath = [[NSBundle mainBundle] pathForResource:@"GraphEdges" ofType:@"csv"];
    data = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&err];
    NSMutableArray *nodesEdges = [[data componentsSeparatedByString: @"\n"] mutableCopy];
    [nodesEdges removeObjectAtIndex:0];
    NSLog(@"Imported %lu edges",(unsigned long)[nodesEdges count]);
    
    dataPath = [[NSBundle mainBundle] pathForResource:@"GraphNodeIndex" ofType:@"csv"];
    data = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&err];
    NSMutableArray *nodesIndex = [[data componentsSeparatedByString: @"\n"] mutableCopy];
    [nodesIndex removeObjectAtIndex:0];
    NSLog(@"Imported %lu node indexes",(unsigned long)[nodesIndex count]);
    
    // Store nodes in core data
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;
    
    long nodeId = 0;
    for (NSString *line in nodesCoordinates) {
        // Get node coordinates
        NSArray *lineSplit = [line componentsSeparatedByString:@","];
        
        NSManagedObject *dataRecord = [NSEntityDescription insertNewObjectForEntityForName:@"StreetNetworkCoordinates" inManagedObjectContext:context];
        if ([lineSplit count] != 2) {
            NSLog(@"ERROR: Can not parse coordinate");
        }
        [dataRecord setValue:[NSNumber numberWithDouble:[lineSplit[0] doubleValue]] forKey:@"latitude"];
        [dataRecord setValue:[NSNumber numberWithDouble:[lineSplit[1] doubleValue]] forKey:@"longitude"];
        [dataRecord setValue:[NSNumber numberWithLongLong:nodeId] forKey:@"nodeId"];
        nodeId++;
    }
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Stored coordinates in core data");
    
    nodeId = 0;
    for (NSString *line in nodesIndex) {
        // Get node indexes
        NSArray *lineSplit = [line componentsSeparatedByString:@","];
        
        NSManagedObject *dataRecord = [NSEntityDescription insertNewObjectForEntityForName:@"StreetNetworkIndex" inManagedObjectContext:context];
        [dataRecord setValue:[NSNumber numberWithLongLong:([lineSplit[0] longLongValue]-1)] forKey:@"fromIndex"];
        [dataRecord setValue:[NSNumber numberWithLongLong:([lineSplit[1] longLongValue]-1)] forKey:@"toIndex"];
        [dataRecord setValue:[NSNumber numberWithLongLong:nodeId] forKey:@"nodeId"];
        nodeId++;
    }
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Stored node indexes in core data");
    
    nodeId = 0;
    for (NSString *line in nodesEdges) {
        // Get node edges
        NSArray *lineSplit = [line componentsSeparatedByString:@","];
        
        NSManagedObject *dataRecord = [NSEntityDescription insertNewObjectForEntityForName:@"StreetNetworkEdges" inManagedObjectContext:context];
        [dataRecord setValue:[NSNumber numberWithLongLong:nodeId] forKey:@"nodeId"];
        [dataRecord setValue:[NSNumber numberWithLongLong:([lineSplit[1] longLongValue]-1)] forKey:@"toNode"];
        [dataRecord setValue:[NSNumber numberWithLongLong:[lineSplit[2] longLongValue]] forKey:@"distCost"];
        [dataRecord setValue:[NSNumber numberWithLongLong:[lineSplit[3] longLongValue]] forKey:@"healthCost"];
        nodeId++;
    }
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Stored node edges in core data");

    NSLog(@"Start laoding StreetNetworkGraph from core data...");
    
    // Load coordinates core data
    NSArray *fetchedObjects = [self getCoreData:@"StreetNetworkCoordinates"];
    self.numNodes = [fetchedObjects count];
    self.nodeLatitude = (double *)malloc(sizeof(double)*self.numNodes);
    self.nodeLongitude = (double *)malloc(sizeof(double)*self.numNodes);
    for (NSManagedObject *obj in fetchedObjects) {
        NSNumber *data = [obj valueForKey:@"latitude"];
        NSNumber *dataId = [obj valueForKey:@"nodeId"];
        self.nodeLatitude[[dataId integerValue]] = [data doubleValue];
        data = [obj valueForKey:@"longitude"];
        self.nodeLongitude[[dataId integerValue]] = [data doubleValue];
    }
    NSLog(@"Coordinates loaded");
    
    // Load index core data
    fetchedObjects = [self getCoreData:@"StreetNetworkIndex"];
    self.nodeIndexFrom = (long *)malloc(sizeof(long)*self.numNodes);
    self.nodeIndexTo = (long *)malloc(sizeof(long)*self.numNodes);
    for (NSManagedObject *obj in fetchedObjects) {
        NSNumber *data = [obj valueForKey:@"fromIndex"];
        NSNumber *dataId = [obj valueForKey:@"nodeId"];
        self.nodeIndexFrom[[dataId integerValue]] = [data integerValue];
        data = [obj valueForKey:@"toIndex"];
        self.nodeIndexTo[[dataId integerValue]] = [data integerValue];
    }
    NSLog(@"Indexes loaded");
    
    // Load edge core data
    fetchedObjects = [self getCoreData:@"StreetNetworkEdges"];
    self.numEdges = [fetchedObjects count];
    self.nodeEdgeTo = (long *)malloc(sizeof(long)*self.numEdges);
    self.edgeCostDist = (long *)malloc(sizeof(long)*self.numEdges);
    self.edgeCostHealth = (long *)malloc(sizeof(long)*self.numEdges);
    for (NSManagedObject *obj in fetchedObjects) {
        NSNumber *data = [obj valueForKey:@"toNode"];
        NSNumber *dataId = [obj valueForKey:@"nodeId"];
        self.nodeEdgeTo[[dataId integerValue]] = [data integerValue];
        data = [obj valueForKey:@"distCost"];
        self.edgeCostDist[[dataId integerValue]] = [data longValue];
        data = [obj valueForKey:@"healthCost"];
        self.edgeCostHealth[[dataId integerValue]] = [data longValue];
    }
    NSLog(@"Edges loaded");
    
    
    NSLog(@"...StreetNetworkGraph loaded");
    
    // Create some default routes
    for (int i=0; i < 7; ++i) {
        Route *route = [[Route alloc] init];
        
        if (i == 0) {
            route.from = [self getGeoCode:@"Wipkingen"];
            route.to = [self getGeoCode:@"Limmatplatz"];
        } else if (i == 1) {
            route.from = [self getGeoCode:@"Werdinsel"];
            route.to = [self getGeoCode:@"Wiedikon"];
        } else if (i == 2) {
            route.from = [self getGeoCode:@"Affoltern Zurich City"];
            route.to = [self getGeoCode:@"Kirche Fluntern"];
        } else if (i == 3) {
            route.from = [self getGeoCode:@"Wipkingen"];
            route.to = [self getGeoCode:@"Zurich"];
        } else if (i == 4) {
            route.from = [self getGeoCode:@"Hirzenbach"];
            route.to = [self getGeoCode:@"Friesenberg"];
        } else if (i == 5) {
            route.from = [self getGeoCode:@"Opfikon"];
            route.to = [self getGeoCode:@"Wollishofen"];
        } else {
            route.from = [self getGeoCode:@"Escherwyssplatz"];
            route.to = [self getGeoCode:@"ETH Zurich"];
        }
        
        route.date = [NSDate date];
        // Crop location name.
        route.from.name = [AppDelegate cropLocation:route.from.name];
        route.to.name = [AppDelegate cropLocation:route.to.name];
        route.descr = [NSString stringWithFormat:@"%@ \u21c4 %@", route.from.name, route.to.name];
        
        NSLog(@"\nRoute: %@", route.descr);
        
        // Get closest node to origin and destination
        int nodeIdStart = [self getClosestNode:route.from];
        int nodeIdEnd = [self getClosestNode:route.to];
        
        route.shortestPath = [self computeShortestRouteFrom:nodeIdStart to:nodeIdEnd cost:1];
        route.shortestPathDistance = route.shortestPath[0];
        route.shortestPathPollution = route.shortestPath[1];
        [route.shortestPath removeObjectAtIndex:0];
        [route.shortestPath removeObjectAtIndex:0];
        NSLog(@"Computed shortest route");
        
        route.healthOptPath = [self computeShortestRouteFrom:nodeIdStart to:nodeIdEnd cost:2];
        route.hOptPathPollution = route.healthOptPath[0];
        route.hOptPathDistance = route.healthOptPath[1];
        [route.healthOptPath removeObjectAtIndex:0];
        [route.healthOptPath removeObjectAtIndex:0];
        NSLog(@"Computed health-optimal route");
        
        NSManagedObject *dataRecord = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryRoutes" inManagedObjectContext:context];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:route];
        [dataRecord setValue:data forKey:@"route"];
    }
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Stored history data in core data");
}

- (Location *) getGeoCode:(NSString *)inputAddress {
    
    Location *location;
    
    NSString *geocodingBaseUrl = @"http://maps.googleapis.com/maps/api/geocode/json?";
    // Use bounds for Zurich in the geocode requrest to bias geocoding for the Zurich area
    NSString *url = [NSString stringWithFormat:@"%@address=%@&sensor=false&language=de&bounds=47.23,8.36|47.54,8.71", geocodingBaseUrl, inputAddress];
    url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURL *queryUrl = [NSURL URLWithString:url];
    
    NSData *data = [NSData dataWithContentsOfURL: queryUrl];
    
    if (data != Nil) {
        location = [self fetchedData:data];
    }
    
    return location;
}

- (Location *) fetchedData:(NSData *)data {
    
    Location *location = [[Location alloc] init];
    
    NSError* error;
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    NSArray* results = [json objectForKey:@"results"];
    if ([results count] == 0) {
        location.name = @"";
        return location;
    }
    NSDictionary *result = [results objectAtIndex:0];
    NSString *address = [result objectForKey:@"formatted_address"];
    NSDictionary *geometry = [result objectForKey:@"geometry"];
    NSDictionary *loc = [geometry objectForKey:@"location"];
    NSString *lat = [loc objectForKey:@"lat"];
    NSString *lon = [loc objectForKey:@"lng"];
    
    //Location *location = [[Location alloc] initWithName:address latitude:@([lat floatValue]) longitude:@([lon floatValue])];
    
    location.latitude = @([lat floatValue]);
    location.longitude = @([lon floatValue]);
    location.name = address;
    
    return location;
    
}

// Return first part of the string (until the first ',')
+ (NSString *)cropLocation:(NSString *)name {
    NSArray *parts = [name componentsSeparatedByString: @","];
    return parts[0];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (NSArray *)getCoreData:(NSString *)entityName
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

// Get closest node in the street network graph
- (int)getClosestNode:(Location *)location {
    
    double minDist = DBL_MAX;
    int nodeId = -1;
    double locLat = [location.latitude doubleValue];
    double locLon = [location.longitude doubleValue];
    
    for (int i=0; i < self.numNodes; ++i) {
        double dist = sqrt(pow(locLat-self.nodeLatitude[i],2) + pow(locLon-self.nodeLongitude[i],2));
        if (dist < minDist) {
            minDist = dist;
            nodeId = i;
        }
    }
    
    NSLog(@"Closest node to location: ID %d, latitude %f, longitude %f", nodeId, self.nodeLatitude[nodeId], self.nodeLongitude[nodeId]);
    
    return nodeId;
}

// Return Value
// kCFCompareLessThan if ptr1 is less than ptr2
// kCFCompareEqualTo if ptr1 and ptr2 are equal
// kCFCompareGreaterThan if ptr1 is greater than ptr2
CFComparisonResult fcompare(const void *ptr1, const void *ptr2, void *info) {
    long a = ((DistToSource *)ptr1)->dist;
    long b = ((DistToSource *)ptr2)->dist;
    
    if (a < b) return kCFCompareLessThan;
    else if (a == b) return kCFCompareEqualTo;
    else return kCFCompareGreaterThan;
}

CFBinaryHeapCallBacks cfCallbacks = { 0, NULL, NULL, NULL, fcompare };

// Compute shortest route with Dijkstra: costId 1: shortest path, costId 2: health-optimal route
- (NSMutableArray *)computeShortestRouteFrom:(int)nodeIdStart to:(int)nodeIdEnd cost:(int)costId {
    
    DistToSource *dist = malloc(sizeof(DistToSource)*self.numNodes);
    long *prev = malloc(sizeof(long)*self.numNodes);
    long *selected = malloc(sizeof(long)*self.numNodes);
    long *otherDist = malloc(sizeof(long)*self.numNodes);
    
    CFBinaryHeapRef Q = CFBinaryHeapCreate(kCFAllocatorDefault, self.numNodes, &cfCallbacks, NULL);
    
    long i, j, d;
    
    long *edgeCost, *otherCost;
    if (costId == 1) {
        edgeCost = self.edgeCostDist;
        otherCost = self.edgeCostHealth;
    } else {
        edgeCost = self.edgeCostHealth;
        otherCost = self.edgeCostDist;
    }
    
    // Init arrays
    for (i=0; i < self.numNodes; ++i) {
        dist[i].nodeId = i;
        dist[i].dist = LONG_MAX;
        prev[i] = -1;
        selected[i] = 0;
    }
    
    selected[nodeIdStart] = 1;
    dist[nodeIdStart].dist = 0;
    otherDist[nodeIdStart] = 0;
    
    CFBinaryHeapAddValue(Q, &dist[nodeIdStart]);
    
    while (CFBinaryHeapGetCount(Q) > 0) {
        DistToSource *minH = (DistToSource *)CFBinaryHeapGetMinimum(Q);
        CFBinaryHeapRemoveMinimumValue(Q);
        
        selected[minH->nodeId] = 1;
        if (minH->nodeId == nodeIdEnd) {
            break;
        }
        
        // Go to all neighbors of current node
        for (i=self.nodeIndexFrom[minH->nodeId]; i <= self.nodeIndexTo[minH->nodeId]; ++i) {
            j = self.nodeEdgeTo[i];
            if (selected[j] == 0) {
                d = dist[minH->nodeId].dist + edgeCost[i];
                
                if (d < dist[j].dist) {
                    dist[j].dist = d;
                    prev[j] = minH->nodeId;
                    CFBinaryHeapAddValue(Q, &dist[j]);
                    otherDist[j] = otherDist[minH->nodeId] + otherCost[i];
                }
                
            }
        }
    }
    
    // Check whether all nodes are reachable and clear coordinates of non-reachable nodes
    //int num;
    //for (i=0; i < self.numNodes; ++i) {
    //    if (selected[i] == 0 && self.nodeLatitude[i] != 0.0) {
    //        num++;
    //    }
    //}
    //NSLog(@"Nodes not reachable: %d",num);

    
    if (selected[nodeIdEnd] == 0) {
        if (costId == 1) {
            NSLog(@"ERROR: Could not find shortest path!");
        } else {
            NSLog(@"ERROR: Could not find health-optimal path!");
        }
    }
    
    // Reconstruct route
    NSMutableArray *path = [[NSMutableArray alloc] init];
    // First two entries are not part of path but its cost (distance and exposure)
    [path addObject:[NSNumber numberWithLong:dist[nodeIdEnd].dist]];
    [path addObject:[NSNumber numberWithLong:otherDist[nodeIdEnd]]];
    i = nodeIdEnd;
    while (i != -1) {
        [path addObject:[NSNumber numberWithLong:i]];
        i = prev[i];
    }
    
    free(dist);
    free(prev);
    free(selected);
    free(otherDist);
    
    return path;
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "ch.ethz.hRoutingCoreDataImport" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"ch.ethz.hRoutingCoreDataImport"];
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"hRoutingCoreDataImport" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"hRoutingCoreDataImport.sqlite"];
    NSLog(@"URL of core data: %@",storeURL);
    
    NSError *error = nil;
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Delete exisiting core data
    NSArray *stores = [_persistentStoreCoordinator persistentStores];
    for(NSPersistentStore *store in stores) {
        [_persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
