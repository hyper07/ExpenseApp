//
//  NSString+Custom.m
//  Expense
//
//  Created by Kibaek Kim on 5/18/15.
//  Copyright (c) 2015 Kibaek. All rights reserved.
//

#import "NSString+Custom.h"

@implementation NSString (Custom)

- (BOOL)empty
{
    return ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0);
}

@end
