/*

  
 */

#import "AssetViewController.h"
#import "MainTableViewController.h"
#import "AssetGridViewController.h"
#import "ReceiptViewController.h"


@implementation CIImage (Convenience)
- (NSData *)aapl_jpegRepresentationWithCompressionQuality:(CGFloat)compressionQuality {
	static CIContext *ciContext = nil;
	if (!ciContext) {
		EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		ciContext = [CIContext contextWithEAGLContext:eaglContext];
	}
	CGImageRef outputImageRef = [ciContext createCGImage:self fromRect:[self extent]];
	UIImage *uiImage = [[UIImage alloc] initWithCGImage:outputImageRef scale:1.0 orientation:UIImageOrientationUp];
	if (outputImageRef) {
		CGImageRelease(outputImageRef);
	}
	NSData *jpegRepresentation = UIImageJPEGRepresentation(uiImage, compressionQuality);
	return jpegRepresentation;
}
@end


@implementation AssetViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDelegate:self];
    [self setDataSource:self];
    
    UIViewController *previousVC = [self backViewController];
    
    if( [previousVC isKindOfClass:[MainTableViewController class]] )
    {
        self.homeButton.title = @"Album";
    }
    else //if( [previousVC isKindOfClass:[AssetGridViewController class]] )
    {
        self.homeButton.title = @"Home";
    }
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    fetch.entity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:appDelegate.managedObjectContext];
    fetch.propertiesToFetch = [NSArray arrayWithObjects:@"name", @"thumbnail", nil];
    fetch.predicate = [NSPredicate predicateWithFormat:@"expenseTitle == %@", appDelegate.selectedExpense.title];    
    
    NSError *error;
    NSArray *receiptList = [appDelegate.managedObjectContext executeFetchRequest:fetch error:&error];
    
    pageList = [[NSMutableArray alloc] init];
    
    __block NSUInteger selectedIndex = 0;
    if( !error && receiptList.count > 0 )
    {
        [receiptList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            ReceiptViewController *p = (ReceiptViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ReceiptViewController"];
            Receipt *myReceipt = (Receipt *)obj;
            
            if( [myReceipt.name isEqualToString:self.receiptName] )
                selectedIndex = idx;
            
            
            p.myReceipt = myReceipt;
            [pageList addObject:p];
            
        }];
    }
    
    ReceiptViewController *currentVC = (ReceiptViewController *)[pageList objectAtIndex:selectedIndex];
    [self setViewControllers:@[currentVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - UIPageViewControllerDelegate
-(UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return pageList[index];
}



-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [pageList indexOfObject:viewController];
    
    if( currentIndex > 0 )
    {
        currentIndex--;
        return [pageList objectAtIndex:currentIndex];
        
    }
    else
    {
        return nil;
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [pageList indexOfObject:viewController];
    
    if( currentIndex < (pageList.count-1) )
    {
        currentIndex++;
        return [pageList objectAtIndex:currentIndex];
    }
    else
    {
        return nil;
    }
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return pageList.count;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    UIViewController *currentVC = self.viewControllers[0];
    NSUInteger currentIndex = [pageList indexOfObject:currentVC];
    return currentIndex;
}

#pragma mark - Method

- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

- (void)deleteReceipt
{
    [appDelegate.managedObjectContext deleteObject:self.myReceipt];
    NSError *error = nil;
    if( [appDelegate.managedObjectContext save:&error] )
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}


#pragma mark - Actions

- (IBAction)handleTrashButtonItem:(id)sender
{
    NSString *string = @"Do you really delete selected receipt?";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete" message:string delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
}

- (IBAction)handleHomeButtonItem:(id)sender
{
    UIViewController *previousVC = [self backViewController];
    
    if( [previousVC isKindOfClass:[MainTableViewController class]] )
    {
        // Go to Album
        AssetGridViewController *agvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AssetGridViewController"];
        agvc.expenseTitle = self.myReceipt.expenseTitle;
        [self.navigationController pushViewController:agvc animated:YES];
    }
    else //if( [previousVC isKindOfClass:[AssetGridViewController class]] )
    {
        // Go to Home
        int index = [appDelegate getViewControllerIndex:[MainTableViewController class]];
        if( index > -1 )
            [self.navigationController popToViewController:[[self.navigationController viewControllers]objectAtIndex:index] animated:YES];
    }
}

#pragma mark - delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( [alertView.title isEqualToString:@"Delete"] &&  buttonIndex == 1 )
    {
        [self deleteReceipt];
    }
}



@end


