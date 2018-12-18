/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A collection view cell that displays a thumbnail image.
  
 */

#import "GridViewCell.h"

@implementation GridViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)updateCell
{
    self.imageView.image = [UIImage imageWithData:self.receipt.thumbnail];
}

@end
