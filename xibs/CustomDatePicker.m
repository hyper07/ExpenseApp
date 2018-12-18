//
//  CustomDatePicker.m
//  Expense
//
//  Created by Kibaek Kim on 5/29/15.
//  Copyright (c) 2015 Kibaek. All rights reserved.
//

#import "CustomDatePicker.h"

NSString *const OPENDATEPICKER = @"OpenDatePicker";
NSString *const CLOSEDATEPICKER = @"CloseDatePicker";
NSString *const SELECTEDDATE = @"SelectedDate";

@implementation CustomDatePicker
@synthesize datePicker;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if( self )
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    
    UIView *view = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CustomDatePicker" owner:self options:nil];
    for( id object in objects)
    {
        if( [object isKindOfClass:[UIView class]] )
        {
            view = object;
            break;
        }
    }
    
    if( view != nil )
    {
        view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:view];
    }
    
    self.clipsToBounds = YES;
}

- (void)drawRect:(CGRect)rect
{
    openedRect = self.frame;
    closedRect = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
    
    self.frame = closedRect;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SELECTEDDATE object:self.datePicker.date];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - method

- (void)closeView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CLOSEDATEPICKER object:self];
    
    // down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.frame = closedRect;
    [UIView commitAnimations];
}

- (void)openView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OPENDATEPICKER object:self];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.frame = openedRect;
    [UIView commitAnimations];
}

#pragma mark - IBAction
- (IBAction)handleCancel:(id)sender
{
    [self closeView];
}
- (IBAction)handleDone:(id)sender
{
    [self closeView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SELECTEDDATE object:self.datePicker.date];
}

@end
