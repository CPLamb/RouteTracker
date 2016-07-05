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
@property (weak, nonatomic) NSArray *directoryContent;
@property (strong, nonnull) NSArray *routerContent;


@property (weak, nonatomic) IBOutlet UISegmentedControl *magazineSelectorControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapSelectorControl;
@property (weak, nonatomic) IBOutlet UIPickerView *filePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *routerPicker;
@property (weak, nonatomic) IBOutlet UIButton *uploadToGoogleButton;
// MARK: - selected list
@property (weak, nonatomic) IBOutlet UILabel *currentListSelected;

@property (weak, nonatomic) IBOutlet UITextField *stopTextField;
@property (weak, nonatomic) IBOutlet UITextField *returnTextField;
@property (weak, nonatomic) IBOutlet UITextField *bundleTextField;
@property (weak, nonatomic) IBOutlet UITextField *copiesTextField;
@property (weak, nonatomic) IBOutlet UITextField *uploadEmailTextField;

@property (weak, nonatomic) IBOutlet UILabel *routeSelectedLabel;

@property (copy, nonnull) NSString* searchString;

- (IBAction)mapTypeControl:(UISegmentedControl *)sender;

@end