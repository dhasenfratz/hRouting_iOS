//
//  HistoryTableViewController.m
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

#import "HistoryTableViewController.h"
#import "Route.h"
#import "MapViewController.h"

@interface HistoryTableViewController ()

@end

@implementation HistoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.historyRoutes = appDelegate.historyEntries;
    
    // Load background image
    UIImage *image;
    if (self.view.frame.size.width == 768 && self.view.frame.size.height == 1024)
        image = [UIImage imageNamed:@"bg768x1024_2.png"];
    else
        image = [UIImage imageNamed:@"bg640x1136_2.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    self.tableView.backgroundView = imageView;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the table
    return [self.historyRoutes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    
    // Set background of cell
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    
    // Set background if cell selected
    UIView *cellSelColorView = [[UIView alloc] init];
    cellSelColorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    cell.selectedBackgroundView = cellSelColorView;
    
    // Set all information of the cell
    
    if (indexPath.row >= [self.historyRoutes count]) {
        NSLog(@"ERROR: Table requires access to non-existing element in history array");
        return cell;
    }
    
    Route *route = (self.historyRoutes)[indexPath.row];
    cell.textLabel.text = route.descr;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    
    // Convert date to string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy',' HH:mm"];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:route.date];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
  
    return cell;
}

#pragma mark - Navigation

// Prepare for segue to map view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
    Route *route = self.historyRoutes[indexPath.row];
    
    MapViewController *mapViewController =  (MapViewController *) segue.destinationViewController;
    // Make a deep copy because route may be deleted while we are in the map view
    // (e.g., by clearing the history in the settings tab)
    NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject:route];
    mapViewController.route = [NSKeyedUnarchiver unarchiveObjectWithData: buffer];
}


@end
