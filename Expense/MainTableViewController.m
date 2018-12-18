//
//  MainTableViewController.m
//  Expense
//
//  Created by Kibaek Kim on 5/18/15.
//  Copyright (c) 2015 Kibaek. All rights reserved.
//

#import "MainTableViewController.h"
#import "Expense.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "AlbumCell.h"
#import "AssetViewController.h"
#import "Receipt.h"
#import "AFNetworking.h"
#import "NSManagedObject+Custom.h"
#import "SSKeychain.h"

@interface MainTableViewController ()

@end

@implementation MainTableViewController

#pragma mark - Default method

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThumbnailTapped:) name:TAPPEDTHUMBNAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUploadTapped:) name:UPLOADEXPENSE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeleteTapped:) name:DELETEEXPENSE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTakePhotoTapped:) name:TAKEPHOTO object:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.navigationItem.title = [NSString stringWithFormat:@"Kibaek Expense v%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return expenseList.count;
}
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return expenseList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumCell *cell = (AlbumCell *)[tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
    
    if( cell == nil )
    {
        cell = [[AlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AlbumCell"];
    }
    
    Expense *expense = (Expense *)[expenseList objectAtIndex:indexPath.row];
    [cell setAlbumData:expense];
    
    return cell;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Expense *data = (Expense *)[expenseList objectAtIndex:section];
    return data.title;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Expense *expense = (Expense *)[expenseList objectAtIndex:section];
    [expense log];
    
    AlbumCell *cell = (AlbumCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    NSInteger count = [cell setAlbumData:expense];
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.tableView.frame.size.width, 20)];
    [label setText:[NSString stringWithFormat:@"%@ - (%li)", [self tableView:tableView titleForHeaderInSection:section], (long)count]];
    [label setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [sectionView addSubview:label];
    
    if( expense.uploadedDate == nil )
    {
        UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        //[uploadBtn setBackgroundImage:[UIImage imageNamed:@"SendButton"] forState:UIControlStateNormal];
        [uploadBtn setTitle:@"Upload" forState:UIControlStateNormal];
        uploadBtn.frame = CGRectMake(200, 5, 60, 30);
        uploadBtn.tag = section;
        [uploadBtn addTarget:self action:@selector(onUpload:) forControlEvents:UIControlEventTouchUpInside];
        [sectionView addSubview:uploadBtn];
        
        UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [photoButton setBackgroundImage:[UIImage imageNamed:@"CameraButton"] forState:UIControlStateNormal];
        photoButton.frame = CGRectMake(270, 5, 40, 30);
        photoButton.tag = section;
        [photoButton addTarget:self action:@selector(onCamera:) forControlEvents:UIControlEventTouchUpInside];
        [sectionView addSubview:photoButton];
    }
    else
    {
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [delBtn setBackgroundImage:[UIImage imageNamed:@"TrashButton"] forState:UIControlStateNormal];
        delBtn.frame = CGRectMake(280, 5, 25, 30);
        delBtn.tag = section;
        [delBtn addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
        [sectionView addSubview:delBtn];
    }
    
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
 
*/


#pragma mark - Custom method
- (void)loadData
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:@"Expense" inManagedObjectContext:appDelegate.managedObjectContext];
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
    fetch.sortDescriptors = [NSArray arrayWithObject:dateSort];
    
    NSError *error = nil;
    expenseList = [appDelegate.managedObjectContext executeFetchRequest:fetch error:&error];
        
    if( error )
    {
        NSLog(@"Failed to fetch objects: %@", [error description]);
    }
    else
    {
        [self.tableView reloadData];
    }
}

-(BOOL)isExistFolder:(NSString *)folderName
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:@"Expense" inManagedObjectContext:appDelegate.managedObjectContext];
    fetch.predicate = [NSPredicate predicateWithFormat:@"title == %@", folderName];
    
    NSError *error = nil;
    NSArray *records = [appDelegate.managedObjectContext executeFetchRequest:fetch error:&error];
    
    if( error )
    {
        NSLog(@"Failed to fetch objects: %@", [error description]);
        return false;
    }
    else
    {
        return records.count > 0;
    }
}

-(void)createFolder:(NSString *)folderName
{
    Expense *expense = [NSEntityDescription insertNewObjectForEntityForName:@"Expense" inManagedObjectContext:appDelegate.managedObjectContext];
    expense.title = folderName;
    expense.createdDate = [appDelegate now];
    
    NSError *error = nil;
    if( [appDelegate.managedObjectContext save:&error] )
    {
        NSString *msg = @"A new folder has been created.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Completed" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSLog(@"Error creating album: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)deleteAlbum:(NSInteger)section
{
    // Delete Model from CoreData =====================
    NSError *error = nil;
    Expense *selectedExpense = (Expense *)[expenseList objectAtIndex:section];
    NSString *expenseTitle = selectedExpense.title;
    [appDelegate.managedObjectContext deleteObject:selectedExpense];
    
    if( [appDelegate.managedObjectContext save:&error] )
    {
        [self loadData];
        [NSThread detachNewThreadSelector:@selector(deleteReceipt:) toTarget:self withObject:expenseTitle];
    }
}

- (void)deleteReceipt:(NSString *)expenseTitle
{
    @autoreleasepool {
        NSError *error = nil;
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        fetch.entity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:appDelegate.managedObjectContext];
        fetch.predicate = [NSPredicate predicateWithFormat:@"expenseTitle == %@", expenseTitle];
        NSArray *receiptList = [appDelegate.managedObjectContext executeFetchRequest:fetch error:&error];
        NSLog(@"receiptList count : %lu", (unsigned long)receiptList.count);
        
        if( !error )
        {
            [receiptList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [appDelegate.managedObjectContext deleteObject:obj];
            }];
            
            if( [appDelegate.managedObjectContext save:&error] )
            {
                
            }
        }
    }
}

- (void)uploadExpense:(NSInteger)section userID:(NSString *)userID password:(NSString *)password
{
    uploadSection = section;
    uploadUserID = userID;
    
    Expense *expense = (Expense *)[expenseList objectAtIndex:section];
    AlbumCell *cell = (AlbumCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:section inSection:0]];
    
    NSInteger alreadyExpenseID = [cell getExpenseIDForUploading];
    NSInteger alreadyUploadedCount = [cell getAlreadyUploadedCount];
    NSDictionary *parameters = @{
                                 @"title" : expense.title,
                                 @"userID" : userID,
                                 @"password" : password,
                                 @"receiptCount" : [NSNumber numberWithInteger:cell.receiptList.count],
                                 @"alreadyExpenseID" : [NSNumber numberWithInteger:alreadyExpenseID],
                                 @"alreadyUploadedCount" : [NSNumber numberWithInteger:alreadyUploadedCount]
                                 };
    
    [appDelegate showActivityIndicator:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://yourapiserver/expense/UploadExpense.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [appDelegate showActivityIndicator:NO];
        
        if([[responseObject objectForKey:@"status"] rangeOfString:@"Success"].location != NSNotFound)
        {
            [SSKeychain deleteAllAccountForService:@"Expense"];
            [SSKeychain setAccount:userID forService:@"Expense"];
            
            NSInteger uploadID = [[responseObject objectForKey:@"uploadID"] integerValue];
            [self uploadReceipt:uploadID receipt:[cell.receiptList objectAtIndex:0]];
        }
        else
        {
            NSString *errorMsg = [responseObject objectForKey:@"msg"];
            NSLog(@"Something Wrong : %@", errorMsg);
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure %@", error.description);
        
        [appDelegate showActivityIndicator:NO];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
}

-(void)uploadReceipt:(NSInteger)expenseID receipt:(Receipt *)receipt
{
    if( [[receipt valueForKey:@"expenseID"] integerValue] == expenseID )
    {
        AlbumCell *cell = (AlbumCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:uploadSection inSection:0]];
        NSInteger myIdx = [cell.receiptList indexOfObject:receipt];
        Receipt *nextReceipt = [cell.receiptList objectAtIndex:(myIdx+1)];
        [self uploadReceipt:expenseID receipt:nextReceipt];
        return; 
    }
    
    //NSLog(@"%@", [receipt.thumbnail base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength]);
    //NSLog(@"%@", [receipt.image base64EncodedDataWithOptions:NSDataBase64Encoding76CharacterLineLength]);
    
  
    
    UIImage *thumbImg = [UIImage imageWithData:receipt.thumbnail];
    NSString *thumbBase64String = [UIImagePNGRepresentation(thumbImg) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    UIImage *receiptImg = [UIImage imageWithData:receipt.image];
    NSString *receiptBase64String = [UIImagePNGRepresentation(receiptImg) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSString *mimetype = @"image/jpeg";
    NSDictionary *parameters = @{
                                 @"expenseID":[NSNumber numberWithInteger:expenseID],
                                 @"name":receipt.name,
                                 @"type":receipt.type,
                                 @"date": [dateFormatter stringFromDate:receipt.date]
                                 //, @"thumbnail": thumbBase64String,
                                 //@"receiptImage": receiptBase64String
                                };
    
    
    //here post url and imagedataa is data conversion of image  and fileimg is the upload image with that name in the php code
    NSMutableURLRequest *request =
    [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://yourapiserver/expense/UploadReceipt.php"
                                    parameters:parameters
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         [formData appendPartWithFileData:receipt.image name:@"receiptImage" fileName:@"receipt.jpg" mimeType:mimetype];
                         [formData appendPartWithFileData:receipt.thumbnail name:@"thumbnail" fileName:@"thumbnail.jpg" mimeType:mimetype];
                         //[formData appendPartWithFileData:UIImageJPEGRepresentation(receiptImg, 1.0) name:@"receiptImage" fileName:@"receipt.jpg" mimeType:mimetype];
                         //[formData appendPartWithFileData:UIImageJPEGRepresentation(thumbImg, 1.0) name:@"thumbnail" fileName:@"thumbnail.jpg" mimeType:mimetype];
                     }
                                         error:nil];
    
    [request setTimeoutInterval:600];
    
    
    //NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"http://yourapiserver/expense/UploadReceipt.php" parameters:parameters error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         [appDelegate showActivityIndicator:NO];
                                         
                                         if([[responseObject objectForKey:@"status"] rangeOfString:@"Success"].location != NSNotFound)
                                         {
                                             NSLog(@"Success %@", responseObject);
                                             
                                             //===== update uploadID and uploadedDate for Receipt Data ===================
                                             NSInteger uploadReceiptID = [[responseObject objectForKey:@"uploadID"] integerValue];
                                             [receipt setUploadedDate:[appDelegate now]];
                                             [receipt setValue:[NSNumber numberWithInteger:uploadReceiptID] forKey:@"uploadID"];
                                             [receipt setValue:[NSNumber numberWithInteger:expenseID] forKey:@"expenseID"];
                                             
                                             NSError *error = nil;
                                             if( [appDelegate.managedObjectContext save:&error] )
                                             {
                                                 //===== check whether has next receipt. ==========================
                                                 //===== if it has a receipt, again call to upload receipt.===========
                                                 AlbumCell *cell = (AlbumCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:uploadSection inSection:0]];
                                                 NSInteger myIdx = [cell.receiptList indexOfObject:receipt];
                                                 if( myIdx == (cell.receiptList.count-1) )
                                                 {
                                                     NSLog(@"Upload success");
                                                     
                                                     //========= update upload status of Expense =======================
                                                     Expense *expense = (Expense *)[expenseList objectAtIndex:uploadSection];
                                                     expense.userID = uploadUserID;
                                                     expense.uploadedDate = [appDelegate now];
                                                     [expense setValue:[NSNumber numberWithInteger:expenseID] forKey:@"uploadID"];
                                                     
                                                     NSError *error = nil;
                                                     if( [appDelegate.managedObjectContext save:&error] )
                                                     {
                                                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload Completed." message:@"All receipts have been uploaded." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                         [alertView show];
                                                     }
                                                     else
                                                     {
                                                         NSLog(@"Failed to update new status of Expense: %@", [error description]);
                                                         
                                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                         [alert show];
                                                     }
                                                     
                                                     [self.tableView reloadData];
                                                 }
                                                 else
                                                 {
                                                     // ===== Again call to upload receipt =========================================
                                                     Receipt *nextReceipt = [cell.receiptList objectAtIndex:(myIdx+1)];
                                                     [self uploadReceipt:expenseID receipt:nextReceipt];
                                                 }
                                             }
                                             else
                                             {
                                                 NSLog(@"Failed to update the entity: %@", [error description]);
                                                 
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                 [alert show];
                                                 
                                                 [self.tableView reloadData];
                                             }
                                         }
                                         else if([[responseObject objectForKey:@"status"] rangeOfString:@"Fail"].location != NSNotFound)
                                         {
                                             NSLog(@"Fail %@", responseObject);
                                             id msgObj = [responseObject objectForKey:@"msg"];
                                             NSString *errorMsg = [msgObj[0] objectForKey:@"message"];
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                             [alert show];
                                             
                                             [self.tableView reloadData];
                                         }
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error);
                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                         [alert show];
                                         [appDelegate showActivityIndicator:NO];
                                         
                                         [self.tableView reloadData];
                                     }];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        float myprog = (float)totalBytesWritten/totalBytesExpectedToWrite*100;
        [appDelegate showProgressBar:myprog];
    }];
    
    // 5. Begin!
    [operation start];
    
    [appDelegate showActivityIndicator:YES];
    
    AlbumCell *cell = (AlbumCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:uploadSection inSection:0]];
    NSInteger currentIndex = [cell.receiptList indexOfObject:receipt];
    NSString *msg = [NSString stringWithFormat:@"Receipt Uploading... %li/%lu", currentIndex+1, (unsigned long)cell.receiptList.count];
    [appDelegate showMessage:msg];
}



#pragma mark - IBAction

- (IBAction)handleCreateFolder:(id)sender
{
    UIAlertView *createAlert = [[UIAlertView alloc] initWithTitle:@"Create a new Folder" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    createAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [createAlert show];
}

#pragma mark - Notification Selectors
- (void)handleThumbnailTapped:(NSNotification *)notification
{
    Receipt *selectedReceipt = (Receipt *)notification.object;
    
    [expenseList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if( [selectedReceipt.expenseTitle isEqualToString:((Expense *)obj).title] )
        {
            appDelegate.selectedExpense = (Expense *)obj;
            return;
        }
    }];
    
    [self performSegueWithIdentifier:@"goDetailView" sender:selectedReceipt];
}

- (void)handleUploadTapped:(NSNotification *)notification
{
    NSInteger idx = [self.tableView indexPathForCell:(AlbumCell *)notification.object].row;
    NSString *string = @"Are you sure upload this selected folder?";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload" message:string delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alertView.tag = idx;
    alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alertView show];
}
- (void)handleDeleteTapped:(NSNotification *)notification
{
    NSInteger idx = [self.tableView indexPathForCell:(AlbumCell *)notification.object].row;
    NSString *string = @"Do you really delete selected folder?";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete" message:string delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.tag = idx;
    [alert show];
}
- (void)handleTakePhotoTapped:(NSNotification *)notification
{
    NSInteger idx = [self.tableView indexPathForCell:(AlbumCell *)notification.object].row;
    appDelegate.selectedExpense = (Expense *)[expenseList objectAtIndex:idx];
    
    [self performSegueWithIdentifier:@"goCameraView" sender:self];
}

#pragma mark - delegate method

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if( alertView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput )
    {
        NSString *userID = [SSKeychain accountForService:@"Expense"];
        if( userID != nil )
        {
            UITextField *userIDField = [alertView textFieldAtIndex:0];
            [userIDField setText:userID];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"selected index : %li", (long)buttonIndex);
    
    if( alertView.alertViewStyle == UIAlertViewStylePlainTextInput && buttonIndex == 1 )
    {
        // For creating Folder
        NSString *folderName = [[alertView textFieldAtIndex:0] text];
        NSString *string = nil;
        
        if( [folderName isEqualToString:@""] )
        {
            string = @"Please enter a folder name";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            if( [self isExistFolder:folderName] )
            {
                string = @"Please enter another Title because is already exist a folder";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                [self createFolder:folderName];
            }
        }
    }
    else
    {
        if( [alertView.title isEqualToString:@"Delete"] &&  buttonIndex == 1 )
        {
            // for deleting folder
            [self deleteAlbum:alertView.tag];
        }
        else if( [alertView.title isEqualToString:@"Upload"] &&  buttonIndex == 1 )
        {
            UITextField *username = [alertView textFieldAtIndex:0];
            UITextField *password = [alertView textFieldAtIndex:1];
            [self uploadExpense:alertView.tag userID:username.text password:password.text];
        }
        else if( [alertView.title isEqualToString:@"Completed"] )
        {
            [self loadData];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"goDetailView"] )
    {
        AssetViewController *avc = [segue destinationViewController];
        
        avc.expenseTitle = ((Receipt *)sender).expenseTitle;
        avc.receiptName = ((Receipt *)sender).name;
        avc.myReceipt = (Receipt *)sender;
    }
    else if( [[segue identifier] isEqualToString:@"goCameraView"] )
    {
        
    }
}




@end
