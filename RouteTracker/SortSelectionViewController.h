//
//  SortSelectionViewController.h
//  ThinkLocalFirst
//
//  Created by Chris Lamb on 5/6/13.
//  Copyright (c) 2013 Chris Lamb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SortSelectionViewController;

@protocol SortSelectionViewControllerDelegate <NSObject>
@optional
- (void)cancelSortView:(SortSelectionViewController *)controller;
- (void)nameSort:(SortSelectionViewController *)controller;
- (void)categorySort:(SortSelectionViewController *)controller;
- (void)driverSort:(SortSelectionViewController *)controller;
- (void)fieldFilter:(SortSelectionViewController *)controller;
 
@end

@interface SortSelectionViewController : UIViewController

@property (weak, nonatomic) id <SortSelectionViewControllerDelegate> delegate;

- (IBAction)sortByCategory:(UIButton *)sender;
- (IBAction)sortByName:(UIButton *)sender;
- (IBAction)sortByDriver:(UIButton *)sender;
- (IBAction)filterForCoupons:(UIButton *)sender;
- (IBAction)cancelButton:(UIButton *)sender;

@end
