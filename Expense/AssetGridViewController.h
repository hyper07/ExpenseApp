/*
 
 */


@import UIKit;
@import Photos;

#import "AppDelegate.h"
#import "Receipt.h"

@interface AssetGridViewController : UICollectionViewController
{
    AppDelegate *appDelegate;
    NSArray *receiptList;
}
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cameraButtonItem;
@property (strong, nonatomic) NSString *expenseTitle;

@end