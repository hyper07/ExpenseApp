//
//  AlbumCell.h
//  Expense
//
//  Created by Kibaek Kim on 5/19/15.
//  Copyright (c) 2015 Kibaek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "Expense.h"
#import "AppDelegate.h"

@interface AlbumCell : UITableViewCell
{
    AppDelegate *appDelegate;
}

@property (nonatomic, weak) IBOutlet UIScrollView *thumbList;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UIButton *uploadButton;
@property (nonatomic, weak) IBOutlet UIButton *trashButton;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;

@property (nonatomic, strong) NSArray *receiptList;

-(void)setAlbumData:(Expense *)expense;
-(NSInteger)getExpenseIDForUploading;
- (NSInteger)getAlreadyUploadedCount;

- (IBAction)handleUpload:(id)sender;
- (IBAction)handleDelete:(id)sender;
- (IBAction)handleTakePhoto:(id)sender;
    

@end
