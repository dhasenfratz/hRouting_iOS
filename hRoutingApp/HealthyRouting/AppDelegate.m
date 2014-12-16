//
//  AppDelegate.m
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
//  Foobar is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
#import "Route.h"
#import "HistoryTableViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Location.BOUNDS_BUTTOM_LEFT_LON_ = 1;
    NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInt:DEFAULT_HIST_SIZE], @"histSize",
                                          [NSNumber numberWithBool:DEFAULT_SWITCH], @"shortestRoute",
                                          [NSNumber numberWithBool:DEFAULT_SWITCH], @"hOptRoute",
                                          [NSNumber numberWithBool:DEFAULT_SWITCH], @"firstRun",
                                          nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];

    // Load user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Load history size from the stored settings
    NSInteger defHistSize = [defaults integerForKey:@"histSize"];
    self.histSize = [NSNumber numberWithInt:(int)defHistSize];
    
    // Load route switch state from stored settings
    self.shortestRoute = [defaults boolForKey:@"shortestRoute"];
    self.hOptimalRoute = [defaults boolForKey:@"hOptRoute"];
    
    // Create empty history list
    self.historyEntries = [NSMutableArray arrayWithCapacity:[self.histSize integerValue]];
    
    // If first run, show a message to user and set the standard data base
    if ([defaults boolForKey:@"firstRun"]) {
        [defaults setBool:FALSE forKey:@"firstRun"];
        [defaults synchronize];
        
        self.firstRun = TRUE;
        
        // Set default core data sqlite DB to standard DB
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"hRoutingCoreDataImport.sqlite"];
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"hRoutingCoreDataImport" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Error: Could not copy preloaded data");
        }
        
        [self addSkipBackupAttributeToItemAtURL:storeURL];
    } else {
        self.firstRun = FALSE;
    }
    
    // Load history core data
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *fetchedObjects = [self getCoreData:@"HistoryRoutes" withContext:context];
    for (NSManagedObject *obj in fetchedObjects) {
        NSData *data = [obj valueForKey:@"route"];
        Route *route = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (self.firstRun) {
            route.date = [NSDate date];
        }
        [self.historyEntries addObject:route];
    }
    // Sort history array
    NSArray *sortedArray;
    sortedArray = [self.historyEntries sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(Route *)a date];
        NSDate *second = [(Route *)b date];
        return [second compare:first];
    }];
    self.historyEntries = [sortedArray mutableCopy];
    
    // Adjust history size if needed.
    NSUInteger hSize = [self.histSize integerValue];
    if ([self.historyEntries count] > hSize) {
        // Remove entries
        NSRange r;
        r.location = hSize;
        r.length = [self.historyEntries count] - hSize;
        [self.historyEntries removeObjectsInRange:r];
    }
    
    // Google Maps API key
    [GMSServices provideAPIKey:GOOGLE_MAPS_API_KEY];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    
    // Fetch all entries in core data HistoryRoutes and delete them.
    NSArray *fetchedObjects = [self getCoreData:@"HistoryRoutes" withContext:context];
    for (NSManagedObject *obj in fetchedObjects) {
        [context deleteObject:obj];
    }
    
    // Store history routes in core data
    for (Route *r in self.historyEntries) {
        NSManagedObject *dataRecord = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryRoutes" inManagedObjectContext:context];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:r];
        [dataRecord setValue:data forKey:@"route"];
    }
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    free(self.nodeLongitude);
    free(self.nodeLatitude);
    free(self.nodeIndexFrom);
    free(self.nodeIndexTo);
    free(self.nodeEdgeTo);
    free(self.edgeCostDist);
    free(self.edgeCostHealth);
}

- (NSArray *)getCoreData:(NSString *)entityName withContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
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

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"hRoutingCoreDataImport" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"hRoutingCoreDataImport.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self addSkipBackupAttributeToItemAtURL:storeURL];
    
    return _persistentStoreCoordinator;
}

// Exclude database from being backed up in icloude
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


@end
