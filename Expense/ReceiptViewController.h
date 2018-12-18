//
//  ReceiptViewController.h
//  Expense
//
//  Created by Kibaek Kim on 7/7/16.
//  Copyright © 2016 Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Receipt.h"
#import "AppDelegate.h"

@interface ReceiptViewController : UIViewController
{
    AppDelegate *appDelegate;
}

@property (strong, nonatomic) Receipt *myReceipt;
@property (weak, nonatomic) IBOutlet UIImageView *receiptView;



@end
