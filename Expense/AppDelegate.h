//
//  AppDelegate.h
//  Expense
//
//  Created by Kibaek Kim on 5/14/15.
//  Copyright (c) 2015 Kibaek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Expense.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIActivityIndicatorView *activityIndiView;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Expense *selectedExpense;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (int)getViewControllerIndex:(Class)aClass;
- (NSDate *)now;
- (void)showActivityIndicator:(BOOL)isShown;
- (void)showProgressBar:(CGFloat)percent;
- (void)showMessage:(NSString *)msg;

@end

