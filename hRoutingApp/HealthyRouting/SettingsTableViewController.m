//
//  SettingsTableViewController.m
//  hRouting
//
//  Created by David Hasenfratz on 22/09/14.
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

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

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
    
    // Get app delegate
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    // Close keyboard after tap
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    // Set current history size
    self.histSizeTextField.text = [self.appDelegate.histSize stringValue];
    // Set numerical keyboard for hist size text field
    [self.histSizeTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    
    // Load background image
    UIImage *image;
    if (self.view.frame.size.width == 768 && self.view.frame.size.height == 1024)
        image = [UIImage imageNamed:@"bg768x1024_3.png"];
    else
        image = [UIImage imageNamed:@"bg640x1136_3.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    self.tableView.backgroundView = imageView;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Headet text color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor grayColor];
    header.textLabel.font = [UIFont systemFontOfSize:15.0];
    
    // Header background color
    header.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.histSizeTextField) {
        // Backspace is ok
        if([string length]==0){
            return YES;
        }
    
        // Limit maximum history size to two digits
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 2) {
            return NO;
        }
    
        // Only allow numberic characters as input
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if ([myCharSet characterIsMember:c]) {
                return YES;
            }
        }
    
        return NO;
    }
    return YES;
}

- (IBAction)histSizeEditEndAction:(id)sender {
    
    // No history size, use existing one.
    if ([self.histSizeTextField.text length] == 0) {
        self.histSizeTextField.text = [self.appDelegate.histSize stringValue];
        return;
    }
    
    NSUInteger hSize = [self.histSizeTextField.text integerValue];
    
    if (hSize == 0) {
        hSize = 1;
        self.histSizeTextField.text = @"1";
    }
    
    // Check current history size and adjust if needed.
    if ([self.appDelegate.historyEntries count] > hSize) {
        // Remove entries
        NSRange r;
        r.location = hSize;
        r.length = [self.appDelegate.historyEntries count] - hSize;
        [self.appDelegate.historyEntries removeObjectsInRange:r];
    }
    
    // Update history size value
    self.appDelegate.histSize = [NSNumber numberWithInt:(int)hSize];
    
    // Update user default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:hSize forKey:@"histSize"];
    [defaults synchronize];
}

- (IBAction)checkForUpdateAction:(id)sender {
    // The yearly pollution map is up to date for the moment
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Update" message:@"Pollution data is up to date."
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert setTag:1];
    [alert show];
}

- (IBAction)clearHistoryAction:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear History" message:@"Remove all entries from the history table."
                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert setTag:2];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // If history should be cleared, check which button was pressed by the user and act accordingly
    if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            // Cancel
            NSLog(@"Canceled history cleaning");
        } else {
            // Ok
            NSLog(@"Removed all objects in the history");
            [self.appDelegate.historyEntries removeAllObjects];
        }
    }
}

@end
