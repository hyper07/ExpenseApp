/*

  
 */

#import "AssetGridViewController.h"

#import "GridViewCell.h"
#import "AssetViewController.h"
#import "MainTableViewController.h"
#import "CustomCameraViewController.h"
#import "UIView+MGBadgeView.h"

@import Photos;

@implementation AssetGridViewController
@synthesize expenseTitle, cameraButtonItem;

static NSString * const CellReuseIdentifier = @"ThumbCell";
static CGSize AssetGridThumbnailSize;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.cameraButtonItem.enabled = appDelegate.selectedExpense.uploadedDate == nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	CGFloat scale = [UIScreen mainScreen].scale;
	CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
	AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadReceipt];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Receipt *selectedReceipt = ((GridViewCell *)sender).receipt;
    AssetViewController *assetViewController = segue.destinationViewController;
    assetViewController.receiptName = selectedReceipt.name;
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = receiptList.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    cell.receipt = [receiptList objectAtIndex:indexPath.row];
    [cell updateCell];
    
    [cell showCheckMark:(cell.receipt.uploadedDate != nil)];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat picDimension = (self.view.frame.size.width - 8) / 3.0f;
    return CGSizeMake(picDimension, picDimension);
}



#pragma mark - Actions

- (IBAction)handleHomeButtonItem:(id)sender
{
    int index = [appDelegate getViewControllerIndex:[MainTableViewController class]];
    [self.navigationController popToViewController:[[self.navigationController viewControllers]objectAtIndex:index] animated:YES];
}

- (IBAction)handleCameraButtonItem:(id)sender
{
    
    //jump to another viewcontroller
     
    int index = [appDelegate getViewControllerIndex:[CustomCameraViewController class]];
    
    if( index > -1 )
    {
        [self.navigationController popToViewController:[[self.navigationController viewControllers]objectAtIndex:index] animated:YES];
    }
    else
    {
        CustomCameraViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomCameraViewController"];
        [self.navigationController pushViewController:cvc animated:YES];
    }
}


#pragma mark - Method

- (void)loadReceipt
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:appDelegate.managedObjectContext];
    fetch.predicate = [NSPredicate predicateWithFormat:@"expenseTitle == %@", self.expenseTitle];
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"name", @"thumbnail", nil]];
    NSError *error;
    receiptList = [appDelegate.managedObjectContext executeFetchRequest:fetch error:&error];
    
    [self.collectionView reloadData];
}

@end


