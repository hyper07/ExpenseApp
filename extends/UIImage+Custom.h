//
//  UIImage+Custom.h
//  Expense
//
//  Created by Kibaek Kim on 5/29/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Custom)

- (UIImage *)generateThumbnail:(CGFloat)sideLen;
- (UIImage *)clone;
- (UIImage *)reviseRotation;

@end
