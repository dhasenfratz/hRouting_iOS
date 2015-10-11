//
//  MyRouteViewController.m
//  hRouting
//
//  Created by David Hasenfratz on 19/09/14.
//  Copyright (c) 2015 David Hasenfratz. All rights reserved.
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

#import "MyRouteViewController.h"
#import "MapViewController.h"

@interface MyRouteViewController ()

@end

@implementation MyRouteViewController

typedef struct {
    long nodeId;
    double dist;
} DistToSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Load background image
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    if (self.view.frame.size.width == 768 && self.view.frame.size.height == 1024)
        imageView.image = [UIImage imageNamed:@"bg768x1024_1.png"];
    else
        imageView.image = [UIImage imageNamed:@"bg640x1136_1.png"];
    // Push background image to the back
    [self.view insertSubview:imageView atIndex:0];
    
    // Set container background (in which the MyRouteTableViewController is located) transparent
    self.containerView.backgroundColor = [UIColor clearColor];
    
    // Bring button to the front
    [self.view bringSubviewToFront:self.computeRouteButton];
    // Set button to white when active and gray if disabled (eg., while loading data)
    [self.computeRouteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.computeRouteButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    // Init load spinner (used to show loading of data and while computing routes)
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.center = CGPointMake(self.view.center.x, self.view.frame.size.height-88);
    self.spinner.hidesWhenStopped = TRUE;
    [self.view addSubview:self.spinner];
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    
    // Show text if the app is started the first time
    if (self.appDelegate.firstRun) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome!" message:@"Enter origin and destination in the area of Zurich (Switzerland) to compute a health-optimal route between the two locations. Check out the exemplary routes stored in your history."
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    // Load street network data from CoreData
    NSLog(@"Start loading StreetNetworkGraph from core data...");
    [self.computeRouteButton setEnabled:FALSE];
    
    // Load data from the database in parallel in the background
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSManagedObjectContext *tmpContext = [[NSManagedObjectContext alloc] init];
        tmpContext.persistentStoreCoordinator = [self.appDelegate persistentStoreCoordinator];
        
        // Load coordinates core data
        // Lock the PersistenStoreCoordinator for the whole process
        NSArray *fetchedObjects = [self.appDelegate getCoreData:@"StreetNetworkCoordinates" withContext:tmpContext];
        self.appDelegate.numNodes = [fetchedObjects count];
        self.appDelegate.nodeLatitude = (double *)malloc(sizeof(double)*self.appDelegate.numNodes);
        self.appDelegate.nodeLongitude = (double *)malloc(sizeof(double)*self.appDelegate.numNodes);
        long nId;
        for (NSManagedObject *obj in fetchedObjects) {
            NSNumber *data = [obj valueForKey:@"latitude"];
            NSNumber *dataId = [obj valueForKey:@"nodeId"];
            nId = [dataId longValue];
            self.appDelegate.nodeLatitude[nId] = [data doubleValue];
            data = [obj valueForKey:@"longitude"];
            self.appDelegate.nodeLongitude[nId] = [data doubleValue];
        }
        NSLog(@"Coordinates loaded");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSManagedObjectContext *tmpContext = [[NSManagedObjectContext alloc] init];
        tmpContext.persistentStoreCoordinator = [self.appDelegate persistentStoreCoordinator];
        
        // Load index core data
        NSArray *fetchedObjects = [self.appDelegate getCoreData:@"StreetNetworkIndex" withContext:tmpContext];
        long numNodes = [fetchedObjects count];
        self.appDelegate.nodeIndexFrom = (long *)malloc(sizeof(long)*numNodes);
        self.appDelegate.nodeIndexTo = (long *)malloc(sizeof(long)*numNodes);
        long nId;
        for (NSManagedObject *obj in fetchedObjects) {
            NSNumber *data = [obj valueForKey:@"fromIndex"];
            NSNumber *dataId = [obj valueForKey:@"nodeId"];
            nId = [dataId longValue];
            self.appDelegate.nodeIndexFrom[nId] = [data integerValue];
            data = [obj valueForKey:@"toIndex"];
            self.appDelegate.nodeIndexTo[nId] = [data integerValue];
        }
        NSLog(@"Indexes loaded");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSManagedObjectContext *tmpContext = [[NSManagedObjectContext alloc] init];
        tmpContext.persistentStoreCoordinator = [self.appDelegate persistentStoreCoordinator];
        
        // Load edge core data
        NSArray *fetchedObjects = [self.appDelegate getCoreData:@"StreetNetworkEdges" withContext:tmpContext];
        self.appDelegate.numEdges = [fetchedObjects count];
        self.appDelegate.nodeEdgeTo = (long *)malloc(sizeof(long)*self.appDelegate.numEdges);
        self.appDelegate.edgeCostDist = (long *)malloc(sizeof(long)*self.appDelegate.numEdges);
        self.appDelegate.edgeCostHealth = (long *)malloc(sizeof(long)*self.appDelegate.numEdges);
        long nId;
        for (NSManagedObject *obj in fetchedObjects) {
            NSNumber *data = [obj valueForKey:@"toNode"];
            NSNumber *dataId = [obj valueForKey:@"nodeId"];
            nId = [dataId longValue];
            self.appDelegate.nodeEdgeTo[nId] = [data integerValue];
            data = [obj valueForKey:@"distCost"];
            self.appDelegate.edgeCostDist[nId] = [data longValue];
            data = [obj valueForKey:@"healthCost"];
            self.appDelegate.edgeCostHealth[nId] = [data longValue];
        }
        NSLog(@"Edges loaded");
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"...StreetNetworkGraph loaded");
        [self.computeRouteButton setEnabled:TRUE];
        [self.spinner stopAnimating];
        
#if ENABLE_TIMING_TEST
        [self startTimingTest];
#endif
#if ENABLE_ALG_TEST
        [self startAlgTest];
#endif
    });
    
}

#if ENABLE_TIMING_TEST
- (void)startTimingTest {
    // Select random source and destination and compute shortest and healthiest paths

    unsigned int start, end;
    NSDate *date;
    double timePassedMsS,timePassedMsH, dist;
    double lat_sec,lon_sec,x_start,x_end,y_start,y_end;

    printf("distance,timeShortest,timeHOpt\n");
    
    for (int i = 0; i < TEST_RUNS; ++i) {
        start = arc4random_uniform((unsigned int)self.appDelegate.numNodes);
        end = arc4random_uniform((unsigned int)self.appDelegate.numNodes);
        
        if (self.appDelegate.nodeLatitude[start] == 0 || self.appDelegate.nodeLatitude[end] == 0) {
            continue;
        }
        
        date = [NSDate date];
#if SHORTEST_ROUTE_ALG == 1
        [self computeShortestDijRouteFrom:start to:end cost:1];
#elif SHORTEST_ROUTE_ALG == 2
        [self computeShortestAstarRouteFrom:start to:end cost:1];
#else
        [self computeShortestDijRouteFrom:start to:end cost:1];
#endif
        timePassedMsS = [date timeIntervalSinceNow] * -1000.0;
        
        date = [NSDate date];
#if SHORTEST_ROUTE_ALG == 1
        [self computeShortestDijRouteFrom:start to:end cost:2];
#elif SHORTEST_ROUTE_ALG == 2
        [self computeShortestAstarRouteFrom:start to:end cost:2];
#else
        [self computeShortestDijRouteFrom:start to:end cost:2];
#endif
        timePassedMsH = [date timeIntervalSinceNow] * -1000.0;
        
        // compute distance
        lat_sec = (appDelegate.nodeLatitude[start]*3600 - 169028.66) / 10000.0;
        lon_sec = (appDelegate.nodeLongitude[start]*3600 - 26782.5) / 10000.0;
        x_start = 200147.07 + 308807.95*lat_sec + 3745.25*pow(lon_sec,2) + 76.63*pow(lat_sec,2) + 119.79*pow(lat_sec,3) - 194.56*pow(lon_sec,2)*lat_sec;
        y_start = 600072.37 + 211455.93*lon_sec - 10938.51*lon_sec*lat_sec - 0.36*lon_sec*pow(lat_sec,2) - 44.53*pow(lon_sec,3);
        
        lat_sec = (appDelegate.nodeLatitude[end]*3600 - 169028.66) / 10000.0;
        lon_sec = (appDelegate.nodeLongitude[end]*3600 - 26782.5) / 10000.0;
        x_end = 200147.07 + 308807.95*lat_sec + 3745.25*pow(lon_sec,2) + 76.63*pow(lat_sec,2) + 119.79*pow(lat_sec,3) - 194.56*pow(lon_sec,2)*lat_sec;
        y_end = 600072.37 + 211455.93*lon_sec - 10938.51*lon_sec*lat_sec - 0.36*lon_sec*pow(lat_sec,2) - 44.53*pow(lon_sec,3);
        
        dist = sqrt(pow(x_start-x_end,2) + pow(y_start-y_end,2));
        
        printf("%f,%f,%f\n",dist,timePassedMsS,timePassedMsH);
    }
    
    
}
#endif

#if ENABLE_ALG_TEST
- (void)startAlgTest {
    // Select random source and destination and compute shortest and healthiest paths
    // with both algorithms and compare results
    
    unsigned int start, end;
    NSMutableArray *pathAlg1, *pathAlg2;
    NSNumber *num1, *num2;
    int fS = 0, fH = 0;
    
    for (int i = 0; i < TEST_RUNS; ++i) {
        start = arc4random_uniform((unsigned int)self.appDelegate.numNodes);
        end = arc4random_uniform((unsigned int)self.appDelegate.numNodes);
        
        
        if (self.appDelegate.nodeLatitude[start] == 0 || self.appDelegate.nodeLatitude[end] == 0) {
            continue;
        }
        
        pathAlg1 = [self computeShortestDijRouteFrom:start to:end cost:1];
        pathAlg2 = [self computeShortestAstarRouteFrom:start to:end cost:1];
        
        num1 = [pathAlg1 objectAtIndex:0];
        num2 = [pathAlg2 objectAtIndex:0];
        
        // Due to rounding errors there can be differences of a few meters
        if ([num2 longValue] - [num1 longValue] > 0) {
            fS++;
        }
        
        pathAlg1 = [self computeShortestDijRouteFrom:start to:end cost:2];
        pathAlg2 = [self computeShortestAstarRouteFrom:start to:end cost:2];
        
        num1 = [pathAlg1 objectAtIndex:0];
        num2 = [pathAlg2 objectAtIndex:0];
        
        // Due to rounding errors there can be differences of a small number of particles
        if ([num2 longValue] - [num1 longValue] > 2000) {
            fH++;
        }
        
        if (i%100 == 0) {
            printf(".");
        }
    }
    printf("\n");
    NSLog(@"Algorithm test successfully completed");
    NSLog(@"Shortest: %d of %d (%.2f %%) failed",fS,TEST_RUNS,(double)fS/(double)TEST_RUNS*100.0);
    NSLog(@"H-Opt: %d of %d (%.2f %%) failed",fH,TEST_RUNS,(double)fH/(double)TEST_RUNS*100.0);
}
#endif

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This function is called (among others) before the child view is created.
// Use this opportunity to store a reference to the child.
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"containerMyRoute"]) {
        self.childViewController = (MyRouteTableViewController *)[segue destinationViewController];
        [self.view addSubview:self.childViewController.view];
        [self.childViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.childViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.childViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    }
    
    // Get the destination view controller and pass some data.
    if ([segueName isEqualToString: @"goToComputedRoutes"]) {
        
        MapViewController *mapViewController =  (MapViewController *) segue.destinationViewController;
        mapViewController.route = self.appDelegate.historyEntries[0];
    }
}

// Get closest node in the street network graph
- (int)getClosestNode:(Location *)location {
    
    double minDist = DBL_MAX;
    int nodeId = -1;
    double locLat = [location.latitude doubleValue];
    double locLon = [location.longitude doubleValue];
    
    for (int i=0; i < self.appDelegate.numNodes; ++i) {
        if (self.appDelegate.nodeLatitude[i] == 0 || self.appDelegate.nodeLongitude[i] == 0) {
            continue;
        }
    
        double dist = sqrt(pow(locLat-self.appDelegate.nodeLatitude[i],2) + pow(locLon-self.appDelegate.nodeLongitude[i],2));
        if (dist < minDist) {
            minDist = dist;
            nodeId = i;
        }
    }
    
    NSLog(@"Closest node to location: ID %d, latitude %f, longitude %f", nodeId, self.appDelegate.nodeLatitude[nodeId], self.appDelegate.nodeLongitude[nodeId]);
    
    return nodeId;
}

// Comparator used for the priority queue
// Return values:
// kCFCompareLessThan if ptr1 is less than ptr2
// kCFCompareEqualTo if ptr1 and ptr2 are equal
// kCFCompareGreaterThan if ptr1 is greater than ptr2
static CFComparisonResult fcompare(const void *ptr1, const void *ptr2, void *info) {
    double a = ((DistToSource *)ptr1)->dist;
    double b = ((DistToSource *)ptr2)->dist;
    
    if (a > b) return kCFCompareGreaterThan;
    if (a < b) return kCFCompareLessThan;
    return kCFCompareEqualTo;
}

// Priority queue callbacks
const CFBinaryHeapCallBacks cfCallbacks = { 0, NULL, NULL, NULL, fcompare };

// Compute shortest route between origin and destination
- (NSMutableArray *)computeShortestRouteFrom:(int)nodeIdStart to:(int)nodeIdEnd cost:(int)costId {

    NSMutableArray *path;
    
    NSDate *date = [NSDate date];
#if SHORTEST_ROUTE_ALG == 1
    path = [self computeShortestDijRouteFrom:nodeIdStart to:nodeIdEnd cost:costId];
#elif SHORTEST_ROUTE_ALG == 2
    path = [self computeShortestAstarRouteFrom:nodeIdStart to:nodeIdEnd cost:costId];
#else
    NSLog(@"Warning: Least-cost algorithm unknown! Using Dijkstra as default");
    path = [self computeShortestDijRouteFrom:nodeIdStart to:nodeIdEnd cost:costId];
#endif
    double timePassedMs = [date timeIntervalSinceNow] * -1000.0;
    NSLog(@"Computation time: %f ms", timePassedMs);
    
    return path;
}

// Compute shortest route with Dijkstra: costId 1: shortest path, costId 2: health-optimal route
- (NSMutableArray *)computeShortestDijRouteFrom:(int)nodeIdStart to:(int)nodeIdEnd cost:(int)costId {
    
    DistToSource *dist = malloc(sizeof(DistToSource)*self.appDelegate.numNodes);
    long *prev = malloc(sizeof(long)*self.appDelegate.numNodes);
    long *selected = malloc(sizeof(long)*self.appDelegate.numNodes);
    long *otherDist = malloc(sizeof(long)*self.appDelegate.numNodes);
    
    CFBinaryHeapRef Q = CFBinaryHeapCreate(NULL, 0, &cfCallbacks, NULL);
    
    long i, j;
    double d;
    
    long *edgeCost, *otherCost;
    if (costId == 1) {
        edgeCost = self.appDelegate.edgeCostDist;
        otherCost = self.appDelegate.edgeCostHealth;
    } else {
        edgeCost = self.appDelegate.edgeCostHealth;
        otherCost = self.appDelegate.edgeCostDist;
    }
    
    // Init arrays
    for (i=0; i < self.appDelegate.numNodes; ++i) {
        dist[i].nodeId = i;
        dist[i].dist = DBL_MAX;
        prev[i] = -1;
        selected[i] = 0;
    }
    
    dist[nodeIdStart].dist = 0.0;
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
        for (i=self.appDelegate.nodeIndexFrom[minH->nodeId]; i <= self.appDelegate.nodeIndexTo[minH->nodeId]; ++i) {
            j = self.appDelegate.nodeEdgeTo[i];
            if (selected[j] == 1) {
                continue;
            }
            
            d = dist[minH->nodeId].dist + edgeCost[i];
                
            if (d < dist[j].dist) {
                dist[j].dist = d;
                prev[j] = minH->nodeId;
                CFBinaryHeapAddValue(Q, &dist[j]);
                otherDist[j] = otherDist[minH->nodeId] + otherCost[i];
            }
        }
    }
    
    if (selected[nodeIdEnd] == 0) {
        if (costId == 1) {
            NSLog(@"ERROR: Could not find shortest path!");
        } else {
            NSLog(@"ERROR: Could not find health-optimal path!");
        }
    }
    
    // Reconstruct route
    NSMutableArray *path = [[NSMutableArray alloc] init];
    // First two entries are not part of path but its costs (distance and exposure)
    [path addObject:[NSNumber numberWithLong:(long)(dist[nodeIdEnd].dist)]];
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
    CFRelease(Q);
    
    return path;
}

// Compute shortest route with A*: costId 1: shortest path, costId 2: health-optimal route
- (NSMutableArray *)computeShortestAstarRouteFrom:(int)nodeIdStart to:(int)nodeIdEnd cost:(int)costId {
    
    DistToSource *fScore = malloc(sizeof(DistToSource)*self.appDelegate.numNodes);
    long *gScore = malloc(sizeof(long)*self.appDelegate.numNodes);

    long *prev = malloc(sizeof(long)*self.appDelegate.numNodes);
    long *inClosedSet = malloc(sizeof(long)*self.appDelegate.numNodes);
    long *otherDist = malloc(sizeof(long)*self.appDelegate.numNodes);
    
    CFBinaryHeapRef openSet = CFBinaryHeapCreate(NULL, 0, &cfCallbacks, NULL);
    
    double heuristicMult = 1.0;
    
    if (costId == 2) {
        heuristicMult = 2262;
    }
    
    long i, j, d;
    
    long *edgeCost, *otherCost;
    if (costId == 1) {
        edgeCost = self.appDelegate.edgeCostDist;
        otherCost = self.appDelegate.edgeCostHealth;
    } else {
        edgeCost = self.appDelegate.edgeCostHealth;
        otherCost = self.appDelegate.edgeCostDist;
    }
    
    double *lat = self.appDelegate.nodeLatitude;
    double *lon = self.appDelegate.nodeLongitude;
    
    // Init arrays
    for (i=0; i < self.appDelegate.numNodes; ++i) {
        fScore[i].nodeId = i;
        gScore[i] = LONG_MAX;
        prev[i] = -1;
        inClosedSet[i] = 0;
    }
    
    gScore[nodeIdStart] = 0;
    
    // convert coordiantes to standard GPS format to CH1903 to compute distance
    double lat_sec = (lat[nodeIdStart]*3600 - 169028.66) / 10000.0;
    double lon_sec = (lon[nodeIdStart]*3600 - 26782.5) / 10000.0;
    double x_start = 200147.07 + 308807.95*lat_sec + 3745.25*pow(lon_sec,2) + 76.63*pow(lat_sec,2) + 119.79*pow(lat_sec,3) - 194.56*pow(lon_sec,2)*lat_sec;
    double y_start = 600072.37 + 211455.93*lon_sec - 10938.51*lon_sec*lat_sec - 0.36*lon_sec*pow(lat_sec,2) - 44.53*pow(lon_sec,3);
    
    lat_sec = (lat[nodeIdEnd]*3600 - 169028.66) / 10000.0;
    lon_sec = (lon[nodeIdEnd]*3600 - 26782.5) / 10000.0;
    double x_end = 200147.07 + 308807.95*lat_sec + 3745.25*pow(lon_sec,2) + 76.63*pow(lat_sec,2) + 119.79*pow(lat_sec,3) - 194.56*pow(lon_sec,2)*lat_sec;
    double y_end = 600072.37 + 211455.93*lon_sec - 10938.51*lon_sec*lat_sec - 0.36*lon_sec*pow(lat_sec,2) - 44.53*pow(lon_sec,3);
    
    fScore[nodeIdStart].dist = sqrt(pow(x_start-x_end,2) + pow(y_start-y_end,2))*heuristicMult;
    
    otherDist[nodeIdStart] = 0;
    
    CFBinaryHeapAddValue(openSet, &fScore[nodeIdStart]);
    
    while (CFBinaryHeapGetCount(openSet) > 0) {
        
        DistToSource *minH = (DistToSource *)CFBinaryHeapGetMinimum(openSet);
        CFBinaryHeapRemoveMinimumValue(openSet);
        inClosedSet[minH->nodeId] = 1;
        if (minH->nodeId == nodeIdEnd) {
            break;
        }
        
        
        // Go to all neighbors of current node
        for (i=self.appDelegate.nodeIndexFrom[minH->nodeId]; i <= self.appDelegate.nodeIndexTo[minH->nodeId]; ++i) {
            j = self.appDelegate.nodeEdgeTo[i];
            
            d = gScore[minH->nodeId] + edgeCost[i];
            
            if (d < gScore[j]) {
                
                prev[j] = minH->nodeId;
                gScore[j] = d;
                otherDist[j] = otherDist[minH->nodeId] + otherCost[i];
                
                lat_sec = (lat[j]*3600 - 169028.66) / 10000.0;
                lon_sec = (lon[j]*3600 - 26782.5) / 10000.0;
                x_start = 200147.07 + 308807.95*lat_sec + 3745.25*pow(lon_sec,2) + 76.63*pow(lat_sec,2) + 119.79*pow(lat_sec,3) - 194.56*pow(lon_sec,2)*lat_sec;
                y_start = 600072.37 + 211455.93*lon_sec - 10938.51*lon_sec*lat_sec - 0.36*lon_sec*pow(lat_sec,2) - 44.53*pow(lon_sec,3);
                
                fScore[j].dist = d + sqrt(pow(x_start-x_end,2) + pow(y_start-y_end,2))*heuristicMult;
                
                CFBinaryHeapAddValue(openSet, &fScore[j]);
            }
        }
    }
    
    if (inClosedSet[nodeIdEnd] == 0) {
        if (costId == 1) {
            NSLog(@"ERROR: Could not find shortest path!");
        } else {
            NSLog(@"ERROR: Could not find health-optimal path!");
        }
    }
    
    // Reconstruct route
    NSMutableArray *path = [[NSMutableArray alloc] init];
    // First two entries are not part of path but its costs (distance and exposure)
    [path addObject:[NSNumber numberWithLong:gScore[nodeIdEnd]]];
    [path addObject:[NSNumber numberWithLong:otherDist[nodeIdEnd]]];
    i = nodeIdEnd;
    while (i != -1) {
        [path addObject:[NSNumber numberWithLong:i]];
        i = prev[i];
    }
    
    free(fScore);
    free(gScore);
    free(prev);
    free(inClosedSet);
    free(otherDist);
    CFRelease(openSet);
    
    return path;
}

// Handle tap events inside the parent view controller
// Resign the from and to textfields to let keyboard disapear
- (IBAction)tapParentViewController:(id)sender {
    [self.childViewController.view endEditing:YES];
}

- (IBAction)computeRouteAction:(id)sender {
    
    // Check whether all required inputs are available
    
    // Check whether locations are given
    Location *from = self.childViewController.from;
    Location *to = self.childViewController.to;
    if ([from.name length] == 0 || [to.name length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Route information missing" message:@"Fill in From and To locations to compute routes."
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    // Check whether a route is chosen for calculation
    BOOL shortestPath = self.childViewController.shortestRouteSwitch.isOn;
    BOOL healthOptPath = self.childViewController.healthOptimalRouteSwitch.isOn;
    if (!shortestPath && !healthOptPath) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Route choice missing" message:@"Select at least one route choice option."
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    // Check whether we are waiting for location service to retrieve my location
    if (([from.name isEqualToString:@"Getting location..."] && from.longitude == Nil) ||
        ([to.name isEqualToString:@"Getting location..."] && to.longitude == Nil)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Resolving location" message:@"Trying to resolve current location."
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    // Check whether locations are inside the supported bounds
    if (![Location insideBounds:from]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location not supported" message:@"Specified From location is outside the supported area of Zurich, Switzerland."
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (![Location insideBounds:to]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location not supported" message:@"Specified To location is outside the supported area of Zurich, Switzerland."
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    // Settings are ok, create route.
    
    // Ensure disptach queue of geocoding job is empty
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{});
    
    
    // Create a new route
    Route *route = [[Route alloc] init];
    route.from = from;
    route.to = to;
    
    // Create new location instances, which can be used the next time (store as default the current location names)
    self.childViewController.from = [from copy];
    self.childViewController.to = [to copy];
    
    
    route.date = [NSDate date];
    // Crop location name
    route.from.name = [MyRouteViewController cropLocation:route.from.name];
    route.to.name = [MyRouteViewController cropLocation:route.to.name];
    route.descr = [NSString stringWithFormat:@"%@ \u21c4 %@", route.from.name, route.to.name];
    
    // Check whether route with same description already exists
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(from.name==%@ AND to.name==%@) OR (to.name==%@ AND from.name==%@)",route.from.name,route.to.name,route.from.name,route.to.name];
    NSArray *res = [self.appDelegate.historyEntries filteredArrayUsingPredicate:predicate];
    
    // Remove route if it already exists.
    if ([res count] == 1) {
        
        [Route copyComputedRoutesOrig:(Route *)res[0] dest:route];
        [self.appDelegate.historyEntries removeObjectIdenticalTo:res[0]];
    } else if ([res count] > 1) {
        NSLog(@"ERROR: Duplicate entries in history table!");
    }
    
    // Push route to the beginning of the array.
    [self.appDelegate.historyEntries insertObject:route atIndex:0];
    if ([self.appDelegate.historyEntries count] > [self.appDelegate.histSize integerValue]) {
        [self.appDelegate.historyEntries removeLastObject];
    }
    
    
    if ((self.appDelegate.shortestRoute && route.shortestPath == Nil) || (self.appDelegate.hOptimalRoute && route.healthOptPath == Nil)) {
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [self.view bringSubviewToFront:self.spinner];
        [self.spinner startAnimating];
        [self.computeRouteButton setEnabled:FALSE];

        // Getting closest node is very fast, we do not have to do this in a thread
        int nodeIdStart = [self getClosestNode:route.from];
        int nodeIdEnd = [self getClosestNode:route.to];
        

        NSLog(@"Found closest nodes, start computing routes");
        
        dispatch_group_t group = dispatch_group_create();
        
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (self.appDelegate.shortestRoute && route.shortestPath == Nil) {
                NSLog(@"Start computing shortest route");
                route.shortestPath = [self computeShortestRouteFrom:nodeIdStart to:nodeIdEnd cost:1];
                // First two entries correspong to the path costs
                route.shortestPathDistance = route.shortestPath[0];
                route.shortestPathPollution = route.shortestPath[1];
                [route.shortestPath removeObjectAtIndex:0];
                [route.shortestPath removeObjectAtIndex:0];
                NSLog(@"Finished computing shortest route");
            }
            dispatch_group_leave(group);
        });
        
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (self.appDelegate.hOptimalRoute && route.healthOptPath == Nil) {
                NSLog(@"Start computing health-optimal route");
                route.healthOptPath = [self computeShortestRouteFrom:nodeIdStart to:nodeIdEnd cost:2];
                // First two entries correspong to the path costs
                route.hOptPathPollution = route.healthOptPath[0];
                route.hOptPathDistance = route.healthOptPath[1];
                [route.healthOptPath removeObjectAtIndex:0];
                [route.healthOptPath removeObjectAtIndex:0];
                NSLog(@"Finished computing health-optimal route");
            }
            dispatch_group_leave(group);
        });
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"Done computing routes, segue to maps");
            [self performSegueWithIdentifier:@"goToComputedRoutes" sender:sender];
            [self.spinner stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [self.computeRouteButton setEnabled:TRUE];
        });
        
    } else {
        [self performSegueWithIdentifier:@"goToComputedRoutes" sender:sender];
    }
}

// Return first part of the string (until the first ',')
+ (NSString *)cropLocation:(NSString *)name {
    NSArray *parts = [name componentsSeparatedByString: @","];
    return parts[0];
}

@end
