//
//  TypeOptionView.h
//  Expense
//
//  Created by Kibaek on 5/9/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLRadioButton.h"

extern NSString *const OPENACTIONSHEET;
extern NSString *const CLOSEACTIONSHEET;
extern NSString *const SELECTEDTYPE;

#define TYPELIST (@[@"Breakfast", @"Lunch", @"Dinner", @"Air Ticket", @"Rail", @"Taxi", @"Car Rental", @"Lodging", @"Gas", @"Business Gift", @"Business Meal", @"Daily Meal Allowance", @"Mexico Mileage Claim", @"Employee Meals&Ent", @"Parking", @"Mileage Claims", @"Toll", @"Communication", @"Office Expense", @"Office Supplies", @"KVC Expense", @"Fringe Benefit", @"Team Lunch", @"Team Dinner", @"Internet", @"Warehouse Expense", @"Marketing", @"Trade Show", @"Art Work", @"Sample-Purchase", @"Art Work-Others", @"RnD", @"Budget Fringe Benefit", @"Evidence"])

@interface TypeOptionView : UIView
{
    CGRect openedRect;
    CGRect closedRect;
    
    NSArray *accumulator;
    UIImage *upArrow;
    UIImage *downArrow;
}


@property(nonatomic, weak) IBOutlet UIImageView *handleView;
@property(nonatomic, weak) IBOutlet UIImageView *arrowView;
@property(nonatomic, weak) IBOutlet UIImageView *bgView;
@property(nonatomic, weak) IBOutlet DLRadioButton *mainRadioBtn;

- (IBAction)onPanHandle:(UITapGestureRecognizer *)sender;
- (IBAction)onTapHandle:(UITapGestureRecognizer *)sender;
- (IBAction)onTapTypeButton:(DLRadioButton *)sender;


- (BOOL)isOpen;

@end
