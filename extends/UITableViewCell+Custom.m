//
//  UITableViewCell+Custom.m
//  KissExpense
//
//  Created by Kibaek Kim on 5/28/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import "UITableViewCell+Custom.h"

@implementation UITableViewCell (Custom)

- (UITableView *)parentTableView
{
    UITableView *tableView = nil;
    UIView *view = self;
    while( view != nil )
    {
        if( [view isKindOfClass:[UITableView class]] )
        {
            tableView = (UITableView *)view;
            break;
        }
        
        view = [view superview];
    }
    
    return tableView;
}

@end
