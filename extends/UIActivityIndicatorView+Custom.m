//
//  UIActivityIndicatorView+Custom.m
//  Expense
//
//  Created by Kibaek Kim on 6/5/15.
//  Copyright (c) 2015 Kibaek. All rights reserved.
//

#import "UIActivityIndicatorView+Custom.h"
#import <objc/runtime.h>

@implementation UIActivityIndicatorView (Custom)

#pragma setter, getter

- (UIProgressView *)progressView
{
    return objc_getAssociatedObject(self, @selector(progressView));
}

-(void)setProgressView:(UIProgressView *)progressView
{
    objc_setAssociatedObject(self, @selector(progressView), progressView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)label
{
    return objc_getAssociatedObject(self, @selector(label));
}

- (void)setLabel:(UILabel *)label
{
    objc_setAssociatedObject(self, @selector(label), label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma bundle method

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    [self.progressView setCenter:CGPointMake(self.center.x, self.center.y + 30)];
    [self.progressView setProgressViewStyle:UIProgressViewStyleBar];
    [self.progressView setHidden:YES];
    [self addSubview:self.progressView];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.label setFont:[UIFont fontWithName:@"hevelica-bold" size:12]];
    [self.label setCenter:CGPointMake(self.center.x, self.center.y + 60)];
    [self.label setHidden:YES];
    [self addSubview:self.label];
}

- (void)drawRect:(CGRect)rect
{
    CGRect myRect = CGRectMake((self.frame.size.width - 270)/2, self.frame.size.height/2 - 50, 270, 150);
    CGRect contentRect = CGRectInset(myRect, 10, 10);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:contentRect cornerRadius:10];
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.5].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 10, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
    [roundedPath fill];
    
    [roundedPath addClip];
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.6].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    
    CGContextMoveToPoint(context, CGRectGetMinX(contentRect), CGRectGetMinY(contentRect)+0.5);
    CGContextAddLineToPoint(context, CGRectGetMaxX(contentRect), CGRectGetMinY(contentRect)+0.5);
    CGContextStrokePath(context);
}

- (void)beginAnimating
{
    [self.progressView setHidden:YES];
    [self.label setHidden:YES];
    
    [self startAnimating];
}

- (void)endAnimating
{
    [self stopAnimating];
    
    [self.progressView setHidden:YES];
    [self.label setHidden:YES];
}


#pragma custom method

- (void)progress:(CGFloat)percent
{
    if( self.progressView.hidden == YES )
       [self.progressView setHidden:NO];
    
    self.progressView.progress = percent/100;
}

- (void)message:(NSString *)msg
{
    if( self.label.hidden == YES )
        [self.label setHidden:NO];
    
    [self.label setText:msg];
}

@end
