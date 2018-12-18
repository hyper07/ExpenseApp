//
//  CustomDatePicker.h
//  KissExpense
//
//  Created by Kibaek Kim on 5/29/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const OPENDATEPICKER;
extern NSString *const CLOSEDATEPICKER;
extern NSString *const SELECTEDDATE;

@interface CustomDatePicker : UIView
{
    CGRect openedRect;
    CGRect closedRect;
}

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;

- (IBAction)handleCancel:(id)sender;
- (IBAction)handleDone:(id)sender;

- (void)closeView;
- (void)openView;

@end
