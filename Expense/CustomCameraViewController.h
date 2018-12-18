//
//  CustomCameraViewController.h
//  Expense
//
//  Created by Kibaek Kim on 5/22/15.
//  Copyright (c) 2015 Kiss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "AppDelegate.h"
#import "CustomDatePicker.h"
#import "Receipt.h"
#import "TypeOptionView.h"
#import "SevenSwitch.h"

@interface CustomCameraViewController : UIViewController
{
    AppDelegate *appDelegate;
    AVCaptureSession *session;
    AVCaptureDeviceInput *videoDeviceInput;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureStillImageOutput *stillImageOutput;
    
    NSArray *typeList;
    
    CAKeyframeAnimation *positionAni;
    
    NSDateFormatter *dateFormatter;
    NSDateFormatter *dateFormatterForFile;
    Receipt *currentReceipt;
    
    NSDate *selectedDate;
    NSInteger selectedTypeIndex;
    
    BOOL isInit;
    
    SevenSwitch *resolutionBtn;
    
    
}

@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet UIImageView *tempImg;
@property (weak, nonatomic) IBOutlet TypeOptionView *actionSheet;
@property (weak, nonatomic) IBOutlet CustomDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UIButton *thumbnailBtn;
@property (weak, nonatomic) IBOutlet UIButton *shutterBtn;

- (IBAction)takePhoto:(id)sender;
- (IBAction)openDatePicker:(id)sender;

@end
