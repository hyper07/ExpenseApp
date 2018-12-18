//
//  UIDatePicker+Custom.m
//  KissExpense
//
//  Created by 101615-DanielMac on 5/16/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import "UIDatePicker+Custom.h"

@implementation UIDatePicker (Custom)

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, 320, 44);
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClick:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:cancelBtn, doneBtn, nil]];
    
    [self.inputAccessoryView addSubview:toolbar];
}

-(void)doneClick:(id)sender
{
    
}

@end
