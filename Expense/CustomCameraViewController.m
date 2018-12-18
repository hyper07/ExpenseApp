//
//  CustomCameraViewController.m
//  Expense
//
//  Created by Kibaek Kim on 5/22/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import "CustomCameraViewController.h"
#import "TypeOptionView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+MGBadgeView.h"
#import "UIImage+Custom.h"
#import "AssetGridViewController.h"
#import "AssetViewController.h"
#import "Receipt.h"

@interface CustomCameraViewController ()

@end

@implementation CustomCameraViewController
@synthesize preview, thumbnailBtn, actionSheet, tempImg, datePickerView, dateBtn, shutterBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangedType:) name:SELECTEDTYPE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangedDate:) name:SELECTEDDATE object:nil];
    
    self.thumbnailBtn.badgeView.badgeValue = 0;
    [self.thumbnailBtn.badgeView setPosition:MGBadgePositionTopRight];
    [self.thumbnailBtn.badgeView setBadgeColor:[UIColor redColor]];
    
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object: captureDevice];
    
    NSError *error;
    videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if( !videoDeviceInput )
    {
        NSLog(@"PANIC : no media input");
    }
    
    if( [session canAddInput:videoDeviceInput] )
    {
        [session addInput:videoDeviceInput];
    }
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setFrame:self.preview.frame];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:stillImageOutput];
    
    positionAni = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAni.fillMode = kCAFillModeForwards;
    positionAni.removedOnCompletion = NO;
    positionAni.duration = 0.3;
    positionAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [self.tempImg setHidden:YES];
    
    CALayer *rootLalyer = [[self view] layer];
    [rootLalyer setMasksToBounds:YES];
    [rootLalyer addSublayer:previewLayer];
    [rootLalyer addSublayer:self.actionSheet.layer];
    [rootLalyer addSublayer:self.tempImg.layer];
    [rootLalyer addSublayer:self.datePickerView.layer];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    dateFormatterForFile = [[NSDateFormatter alloc] init];
    [dateFormatterForFile setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //dateFormatterForFile.dateStyle = NSDateFormatterLongStyle;
    
    CGRect switchRect = CGRectMake(0, 0, 77, 27);
    resolutionBtn = [[SevenSwitch alloc] initWithFrame:switchRect];
    resolutionBtn.offLabel.textColor = [UIColor blueColor];
    resolutionBtn.onLabel.textColor = [UIColor whiteColor];
    resolutionBtn.offLabel.text = @"LOW R.";
    resolutionBtn.onLabel.text = @"HIGH R.";
    [resolutionBtn addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *rightButtonBar = [[UIBarButtonItem alloc] initWithCustomView:resolutionBtn];
    self.navigationItem.rightBarButtonItem = rightButtonBar;
    
    
    
    //self.navigationItem.backBarButtonItem.title = @"HOME";
    //self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"< Back"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(goBack:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [session startRunning];
    [positionAni setDelegate:self];
    
    isInit = YES;
    currentReceipt = nil;
    self.tempImg.image = nil;
    [self.tempImg setHidden:YES];
    [self.thumbnailBtn setBackgroundImage:nil forState:UIControlStateNormal];
    self.thumbnailBtn.badgeView.badgeValue = 0;
    self.thumbnailBtn.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [session stopRunning];
    [positionAni setDelegate:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"goDetailViewFromCamera"] )
    {
        AssetViewController *avc = [segue destinationViewController];
        avc.receiptName = currentReceipt.name;
        avc.expenseTitle = currentReceipt.expenseTitle;
        avc.myReceipt = currentReceipt;
    }
    else if( [[segue identifier] isEqualToString:@"goAlbumGridView"] )
    {
        AssetGridViewController *avc = [segue destinationViewController];
        avc.expenseTitle = appDelegate.selectedExpense.title;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[videoDeviceInput device]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SELECTEDTYPE object:nil];
    
    [previewLayer removeFromSuperlayer];
    [self.actionSheet.layer removeFromSuperlayer];
    [self.tempImg.layer removeFromSuperlayer];
    [self.datePickerView.layer removeFromSuperlayer];
    
    for(AVCaptureInput *input1 in session.inputs) {
        [session removeInput:input1];
    }
    
    for(AVCaptureOutput *output1 in session.outputs) {
        [session removeOutput:output1];
    }
    
    [resolutionBtn removeTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
}


#pragma mark - NSNotifycation Observer

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)onChangedType:(NSNotification *)notification
{
    UIButton *btn = (UIButton *)notification.object;
    selectedTypeIndex = btn.tag;
    
    NSString *selectedType = TYPELIST[selectedTypeIndex];
    
    NSLog(@"selected Type : %@", selectedType);
    
    //[self.navigationController.navigationBar.topItem setTitle:selectedType];
    [self.navigationController.navigationBar.topItem setTitle:btn.titleLabel.text];
    
    if( isInit )
    {
        isInit = NO;
    }
    else
    {
        if( self.actionSheet.alpha < 0.1 )
            [self actionSheetFadeIn];
        else
            [self actionSheetFadeOut];
    }
}

- (void)onChangedDate:(NSNotification *)notification
{
    selectedDate = (NSDate *)notification.object;
    NSString *dateStr = [dateFormatter stringFromDate:selectedDate];
    
    [self.dateBtn setTitle:dateStr forState:UIControlStateNormal];
}

- (void)switchChanged:(SevenSwitch *)sender {
    NSLog(@"Changed value to: %@", sender.on ? @"ON" : @"OFF");
    
    if( sender.on )
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    else
        [session setSessionPreset:AVCaptureSessionPresetHigh];
}

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IBAction

- (IBAction)takePhoto:(id)sender
{
    self.thumbnailBtn.enabled = NO;
    self.shutterBtn.enabled = NO;
    
    AVCaptureConnection *videoConnection = nil;
    
    for( AVCaptureConnection *conn in stillImageOutput.connections )
    {
        for( AVCaptureInputPort *port in [conn inputPorts] )
        {
            if( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = conn;
                break;
            }
        }
        
        if( videoConnection )
        {
            break;
        }
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if( imageDataSampleBuffer != NULL )
        {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *originalImage = [UIImage imageWithData:imageData];
            UIImage *thumbImage = [originalImage generateThumbnail:120];
            
            self.tempImg.image = thumbImage;
            [self.tempImg setHidden:NO];
            [self moveFromPoint:self.preview.center toPoint:self.thumbnailBtn.center];
            
            [self.thumbnailBtn showProgressView:YES];
            [NSThread detachNewThreadSelector:@selector(savePhoto:) toTarget:self withObject:originalImage];
        }
    }];
    
    [self actionSheetFadeIn];
}


- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [previewLayer captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
    
    [self actionSheetFadeOut];
}

- (IBAction)openDatePicker:(id)sender
{
    [self.datePickerView openView];
}



#pragma mark - method

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    AVCaptureDevice *device = [videoDeviceInput device];
    NSError *error = nil;
    if ([device lockForConfiguration:&error])
    {
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
        {
            [device setFocusMode:focusMode];
            [device setFocusPointOfInterest:point];
        }
        if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
        {
            [device setExposureMode:exposureMode];
            [device setExposurePointOfInterest:point];
        }
        [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
        [device unlockForConfiguration];
    }
    else
    {
        NSLog(@"%@", error);
    }
}

// Add it to the photo library
- (void)savePhoto:(UIImage *)image
{
    @autoreleasepool {
        
        NSString *expenseTitle = appDelegate.selectedExpense.title;
        NSString *selectedType = TYPELIST[selectedTypeIndex];
        NSString *dateString = [dateFormatterForFile stringFromDate:[NSDate date]];
        NSString *receiptName = [NSString stringWithFormat:@"%@_%@", selectedType, dateString];
        UIImage *thumbImage = [image generateThumbnail:120];

        currentReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:appDelegate.managedObjectContext];
        currentReceipt.expenseTitle = expenseTitle;
        currentReceipt.name = receiptName;
        currentReceipt.type = selectedType;
        currentReceipt.date = selectedDate;
        currentReceipt.thumbnail = UIImageJPEGRepresentation(thumbImage, 1);
        //currentReceipt.image = UIImageJPEGRepresentation([self grayImage:image], 1);
        currentReceipt.image = UIImageJPEGRepresentation([image reviseRotation], 1);
        
        NSError *error = nil;
        if( [appDelegate.managedObjectContext save:&error] == NO )
        {
            NSLog(@"Failed to add entity: %@", [error description]);
        }
        
        self.thumbnailBtn.enabled = YES;
        self.shutterBtn.enabled = YES;
        [self.thumbnailBtn showProgressView:NO];
    }
}

- (UIImage *)grayImage:(UIImage *)image
{
    
    UIImage *inputImage = [image clone];
    
    CGRect imageRect = CGRectMake(0, 0, inputImage.size.width, inputImage.size.height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(nil, inputImage.size.width, inputImage.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    
    CGAffineTransform ctm = CGContextGetCTM(context);
    CGAffineTransformRotate(ctm, M_PI/2);
    CGContextConcatCTM(context, ctm);
    
    CGContextDrawImage(context, imageRect, [inputImage CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return newImage;
}

- (void)moveFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
    CGPoint c1 = CGPointMake(start.x - (start.x - end.x)*0.7, start.y);
    CGPoint c2 = CGPointMake(end.x, end.y - (end.y - start.y)*0.7);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addCurveToPoint:end controlPoint1:c1 controlPoint2:c2];
    
    [positionAni setPath:path.CGPath];
    
    [self.tempImg.layer addAnimation:positionAni forKey:@"animation.position"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"animation stop");
    
    [self.thumbnailBtn setBackgroundImage:self.tempImg.image forState:UIControlStateNormal];
    [self.tempImg setHidden:YES];
    [self.tempImg.layer removeAnimationForKey:@"animation.position"];
    
    self.thumbnailBtn.badgeView.badgeValue++;
}

- (void)actionSheetFadeIn
{
    if( self.actionSheet.alpha < 1.0 )
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [self.actionSheet setAlpha:1.0];
        [UIView commitAnimations];
    }
}

- (void)actionSheetFadeOut
{
    if( [self.actionSheet isOpen] == YES && self.actionSheet.alpha > 0.1 )
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [self.actionSheet setAlpha:0.05];
        [UIView commitAnimations];
    }
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
