//
//  HistoryTableViewController.h
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

/**
 * The HistoryTableViewController class is responsible for the History navigation tab.
 * The tab is used to list previously looked up routes.
 */
@interface HistoryTableViewController : UITableViewController

/**
 * A link to the array holding all previously computed routes in a time-ordered fashion.
 *
 * @see AppDelegate historyEntries
 */
@property (nonatomic, weak) NSMutableArray *historyRoutes;

@end
