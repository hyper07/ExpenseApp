//
//  NSManagedObject+Custom.m
//  KissExpense
//
//  Created by Kibaek Kim on 6/5/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import "NSManagedObject+Custom.h"

@implementation NSManagedObject (Custom)

-(void)log
{
    NSLog(@" ==== start logging ====");
    for( NSString *attrName in self.entity.attributesByName )
    {
        id value = [self valueForKey:attrName];
        
        if( [value isKindOfClass:[NSData class]] )
            NSLog(@"attribute %@ = %@", attrName, @"NSData");
        else
            NSLog(@"attribute %@ = %@", attrName, value);
    }
    NSLog(@"---- end ----");
}

@end
