//
//  MainTableViewController.h
//  KissExpense
//
//  Created by Kibaek Kim on 5/18/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "AppDelegate.h"

@interface MainTableViewController : UITableViewController< UIAlertViewDelegate >
{
    AppDelegate *appDelegate;
    NSDateFormatter *dateFormatter;
    NSArray *expenseList;
    PHAsset *selectedAsset;
    
    NSInteger uploadSection;
    NSString *uploadUserID;
}

- (IBAction)handleCreateFolder:(id)sender;

@end
