/*

  
 */

@import UIKit;
@import Photos;
#import "AppDelegate.h"
#import "Receipt.h"


@interface AssetViewController : UIPageViewController<UINavigationBarDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate>
{
    AppDelegate *appDelegate;
    NSMutableArray *pageList;
}


//@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;

@property (strong, nonatomic) NSString *expenseTitle;
@property (strong, nonatomic) NSString *receiptName;
@property (strong, nonatomic) Receipt *myReceipt;

@end
