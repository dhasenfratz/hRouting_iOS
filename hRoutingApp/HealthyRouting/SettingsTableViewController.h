//
//  SettingsTableViewController.h
//  hRouting
//
//  Created by David Hasenfratz on 22/09/14.
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

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

/**
 * The SettingsTableViewController class is responsible for the Settings navigation tab.
 * The tab is used to let the user adjust different app settings, such as history size.
 */
@interface SettingsTableViewController : UITableViewController

/**
 * Points to the unique appDelegate of the app.
 */
@property (weak, nonatomic) AppDelegate *appDelegate;

/**
 * Text field to enter the maximum size of the history list.
 */
@property (weak, nonatomic) IBOutlet UITextField *histSizeTextField;

/**
 * Called when the user inputs a new maximum history size.
 * The method checks whether the entered size is within a valid range (1-99)
 * and adjust the size of the history array if required.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)histSizeEditEndAction:(id)sender;

/**
 * Called when the button to update pollution data is pressed.
 * Note that updating pollution data is not yet supported!
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)checkForUpdateAction:(id)sender;

/**
 * Called when the clear history button is pressed.
 * The method reconfirms the action and upon confirmation
 * removes all entries from the history array.
 *
 * @param sender  Object of the sender view.
 */
- (IBAction)clearHistoryAction:(id)sender;

@end
