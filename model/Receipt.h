//
//  Receipt.h
//  Expense
//
//  Created by Kibaek Kim on 5/29/15.
//  Copyright (c) 2015 Kibaek. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Receipt : NSManagedObject


@property (nonatomic) NSInteger expenseID;
@property (nonatomic, retain) NSString * expenseTitle;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSData *thumbnail;
@property (nonatomic, retain) NSData *image;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate * uploadedDate;
@property (nonatomic) NSInteger uploadID;
@property (nonatomic, retain) NSDate * createdDate;

@end
