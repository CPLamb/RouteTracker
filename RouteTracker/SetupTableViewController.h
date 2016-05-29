//
//  SetupTableViewController.h
//  RouteTracker
//
//  Created by Chris Lamb on 12/29/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemberListData.h"

@class SetupTableViewController;

@protocol SetupTableViewControllerDelegate  <NSObject>

@optional
- (void)dataFileSelect:(SetupTableViewController *)controller;
- (void)changeSpreadsheet:(SetupTableViewController *)controller;
@end

@interface SetupTableViewController : UITableViewController

@property (weak, nonatomic) id <SetupTableViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *directoryContent;

@property (weak, nonatomic) IBOutlet UITableView *setupTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *magazineSelectorControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapSelectorControl;
@property (weak, nonatomic) IBOutlet UIPickerView *filePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *driverPicker;
@property (weak, nonatomic) IBOutlet UIButton *uploadToGoogleButton;


- (IBAction)mapTypeControl:(UISegmentedControl *)sender;

@end
