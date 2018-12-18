//
//  AlbumCell.m
//  KissExpense
//
//  Created by Kibaek Kim on 5/19/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import "AlbumCell.h"
#import <Photos/Photos.h>
#import "UITableViewCell+Custom.h"
#import "Receipt.h"
#import "NSManagedObject+Custom.h"
#import "UIView+MGBadgeView.h"

@implementation AlbumCell
@synthesize thumbList, receiptList, title, uploadButton, trashButton, cameraButton;

- (void)awakeFromNib {
    // Initialization code
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [super awakeFromNib];
    
}

- (void)reset
{
    NSArray *views = [self.thumbList subviews];
    for( UIView *view in views)
    {
        [view showCheckMark:NO];
        [view removeFromSuperview];
    }
}

- (void)setAlbumData:(Expense *)expense
{
    [self reset];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:appDelegate.managedObjectContext];
    fetch.propertiesToFetch = [NSArray arrayWithObjects:@"name", @"thumbnail", nil];
    fetch.predicate = [NSPredicate predicateWithFormat:@"expenseTitle == %@", expense.title];
    
    NSError *error;
    self.receiptList = [appDelegate.managedObjectContext executeFetchRequest:fetch error:&error];
    
    if( !error )
    {
        [self.receiptList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [((Receipt *)obj) log];
            
            UIImageView *thumbImage = [[UIImageView alloc] init];
            thumbImage.frame = CGRectMake(105*idx + 5, 5, 100, 115);
            thumbImage.image = [UIImage imageWithData:((Receipt *)obj).thumbnail];
            thumbImage.tag = idx;
            [thumbImage setUserInteractionEnabled:YES];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThumbImageTap:)];
            [thumbImage addGestureRecognizer:singleTap];
            
            [self.thumbList addSubview:thumbImage];
            
            if( ((Receipt *)obj).uploadedDate != nil )
            {
                [thumbImage showCheckMark:YES];
            }
        }];
        
        self.thumbList.contentSize = CGSizeMake(100*self.receiptList.count + 5*(self.receiptList.count+1), self.thumbList.frame.size.height);
        [self.thumbList setCanCancelContentTouches:YES];
    }
    
    [self.title setText:[NSString stringWithFormat:@"%@ - (%li)", expense.title, (long)self.receiptList.count]];

    if( expense.uploadedDate == nil )
    {
        [self.uploadButton setEnabled:YES];
        [self.cameraButton setEnabled:YES];
        [self.trashButton setEnabled:YES];
        
    }
    else
    {
        [self.uploadButton setEnabled:NO];
        [self.cameraButton setEnabled:NO];
        [self.trashButton setEnabled:YES];
    }
}

- (NSInteger)getExpenseIDForUploading
{
    __block NSInteger expenseID = -1;
    __block NSInteger uploadedCount = 0;
    [self.receiptList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        Receipt *receipt = (Receipt *)obj;
        if( receipt.uploadedDate != nil )
        {
            expenseID = [[receipt valueForKey:@"expenseID"] integerValue];
            uploadedCount++;
        }
    }];
    
    if( expenseID > -1 && uploadedCount < self.receiptList.count )
    {
        return expenseID;
    }
    else
    {
        return -1;
    }
}


- (NSInteger)getAlreadyUploadedCount
{
    __block NSInteger uploadedCount = 0;
    [self.receiptList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if( ((Receipt *)obj).uploadedDate != nil )
        {
            uploadedCount++;
        }
    }];
    
    return uploadedCount;
}

#pragma mark - IBAction
- (IBAction)handleUpload:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UPLOADEXPENSE object:self];
}
- (IBAction)handleDelete:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DELETEEXPENSE object:self];
}
- (IBAction)handleTakePhoto:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TAKEPHOTO object:self];
}

#pragma mark - UIGestureRecognizer
- (void)handleThumbImageTap:(UIGestureRecognizer *)gestureRecognizer
{
    Receipt *selectedReceipt = (Receipt *)[self.receiptList objectAtIndex:gestureRecognizer.view.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAPPEDTHUMBNAIL object:selectedReceipt];
}

@end
