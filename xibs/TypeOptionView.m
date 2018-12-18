//
//  TypeOptionView.m
//  KissExpense
//
//  Created by Kibaek Kim on 5/9/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import "TypeOptionView.h"

NSString *const OPENACTIONSHEET = @"OpenActionSheet";
NSString *const CLOSEACTIONSHEET = @"CloseActionSheet";
NSString *const SELECTEDTYPE = @"SelectedType";

@implementation TypeOptionView
@synthesize arrowView, handleView, bgView, mainRadioBtn;

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
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TypeOptionView" owner:self options:nil];
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
    
    upArrow = [UIImage imageNamed:@"ArrowUp"];
    downArrow = [UIImage imageNamed:@"ArrowDown"];
    
    self.arrowView.image = upArrow;
    
    self.backgroundColor = [UIColor clearColor];
    
    //UIView *maskView = [[UIView alloc] initWithFrame:self.frame];
    //[self.superview addSubview:maskView];
    //[self setMaskView:maskView];
}

- (void)drawRect:(CGRect)rect
{
    openedRect = self.frame;
    closedRect = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.bgView.frame.size.height + 20, self.frame.size.width, self.frame.size.height);
    
    if( IS_IPHONE_X )
    {
        openedRect.origin.y = openedRect.origin.y + 25;
        closedRect.origin.y = closedRect.origin.y + 25;
        self.frame = openedRect;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SELECTEDTYPE object:self.mainRadioBtn];
}

- (void)closeView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CLOSEACTIONSHEET object:self];
    
    // down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.frame = closedRect;
    [UIView commitAnimations];
    
    self.arrowView.image = downArrow;
}

- (void)openView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OPENACTIONSHEET object:self];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.frame = openedRect;
    [UIView commitAnimations];
    
    self.arrowView.image = upArrow;
}

- (BOOL)isOpen
{
    return CGRectEqualToRect(self.frame, openedRect);
}

#pragma mark - IBAction

- (IBAction)onPanHandle:(UIPanGestureRecognizer *)sender
{
    CGPoint vel = [sender velocityInView:self];
    
    NSLog(@"Pan Vel : %f, %f", vel.x, vel.y);
    
    if (vel.y > 5 && ABS(vel.x) < 50 )
    {
        [self openView];
    }
    else if (vel.y < 5 && ABS(vel.x) < 50 )
    {
        [self closeView];
    }
}

- (IBAction)onTapHandle:(UITapGestureRecognizer *)sender
{
    if( self.arrowView.image == downArrow )
    {
        [self openView];
    }
    else if( self.arrowView.image == upArrow )
    {
        [self closeView];
    }
}

- (IBAction)onTapTypeButton:(DLRadioButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SELECTEDTYPE object:sender];
}

@end
