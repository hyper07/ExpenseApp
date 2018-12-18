//
//  ReceiptViewController.m
//  Expense
//
//  Created by Kibaek Kim on 7/7/16.
//  Copyright © 2016 Kiss. All rights reserved.
//

#import "ReceiptViewController.h"

@interface ReceiptViewController ()

@end

@implementation ReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.receiptView setImage:[UIImage imageWithData:self.myReceipt.image]];
    
    /*
    if( self.myReceipt.image == nil )
    {
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        fetch.entity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:appDelegate.managedObjectContext];
        fetch.propertiesToFetch = [NSArray arrayWithObjects:@"image", nil];
        fetch.predicate = [NSPredicate predicateWithFormat:@"name == %@", self.myReceipt.name];
        
        NSError *error;
        NSArray *receiptList = [appDelegate.managedObjectContext executeFetchRequest:fetch error:&error];
        
        if( !error && receiptList.count > 0 )
        {
            [receiptList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
             {
                 Receipt *foundReceipt = (Receipt *)obj;
                 self.myReceipt.image = foundReceipt.image;
                 
                 [self.receiptView setImage:[UIImage imageWithData:foundReceipt.image]];
             }];
        }
    }
    */
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.receiptView setImage:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
