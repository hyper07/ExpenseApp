//
//  UIActivityIndicatorView+Custom.h
//  KissExpense
//
//  Created by Kibaek Kim on 6/5/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityIndicatorView (Custom)


@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *label;


- (void)progress:(CGFloat)percent;
- (void)message:(NSString *)msg;
- (void)beginAnimating;
- (void)endAnimating;

@end
