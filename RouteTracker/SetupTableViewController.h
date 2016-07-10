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
- (void)dataFileSelect:(nonnull SetupTableViewController *)controller;
- (void)changeSpreadsheet:(nonnull SetupTableViewController *)controller;
@end

@interface SetupTableViewController : UITableViewController

@property (weak, nonatomic, nullable) id <SetupTableViewControllerDelegate> delegate;
@property (weak, nonatomic, nullable) NSArray *directoryContent;
@property (strong, nonatomic, nonnull) NSArray *routerContent;

@property (weak, nonatomic, nullable) IBOutlet UISegmentedControl *mapSelectorControl;
@property (weak, nonatomic, nullable) IBOutlet UIPickerView *filePicker;
@property (weak, nonatomic, nullable) IBOutlet UIPickerView *routerPicker;
@property (weak, nonatomic, nullable) IBOutlet UIButton *uploadToGoogleButton;
// MARK: - selected list
@property (weak, nonatomic, nullable) IBOutlet UILabel *currentListSelected;

@property (weak, nonatomic, nullable) IBOutlet UITextField *stopTextField;
@property (weak, nonatomic, nullable) IBOutlet UITextField *returnTextField;
@property (weak, nonatomic, nullable) IBOutlet UITextField *bundleTextField;
@property (weak, nonatomic, nullable) IBOutlet UITextField *copiesTextField;
@property (weak, nonatomic, nullable) IBOutlet UITextField *uploadEmailTextField;
@property (weak, nonatomic, nullable) IBOutlet UITextField *copiesBoxBundle;
@property (weak, nonatomic, nullable) IBOutlet UITextField *upload2EmailTextField;

@property (weak, nonatomic, nullable) IBOutlet UILabel *routeSelectedLabel;

@property (copy, nonnull) NSString* searchString;

- (IBAction)mapTypeControl:(nonnull UISegmentedControl *)sender;

@end
