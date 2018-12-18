/*

  
 */

@import UIKit;
#import "Receipt.h"


@interface GridViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) Receipt *receipt;

- (void)updateCell;

@end
