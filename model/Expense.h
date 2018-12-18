//
//  Expense.h
//  Expense
//
//  Created by Kibaek Kim on 5/16/15.
//  Copyright (c) 2015 Kibaek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Expense : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSDate * uploadedDate;
@property (nonatomic) NSInteger uploadID;
@property (nonatomic, retain) NSDate * createdDate;

@end
