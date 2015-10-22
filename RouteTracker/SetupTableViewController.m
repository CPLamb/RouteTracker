//
//  SetupTableViewController.m
//  RouteTracker
//
//  Created by Chris Lamb on 12/29/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import "SetupTableViewController.h"

@interface SetupTableViewController ()
@property NSArray *driverList;

- (IBAction)selectSpreadsheetControl:(UISegmentedControl *)sender;

@end

@implementation SetupTableViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
  NSLog(@"SetupViewController viewWillAppear");

  self.magazineSelectorControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_spreadsheet"];
  
  self.mapSelectorControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_map_type"];

}

- (void)viewWillDisappear:(BOOL)animated {
 //   NSLog(@"view WILL Disappear, used to change the spreadsheet");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods


- (IBAction)selectSpreadsheetControl:(UISegmentedControl *)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"selected_spreadsheet"];
    NSLog(@"selects which spreadsheet to display %ld", (long)sender.selectedSegmentIndex);
    
    [self.delegate dataFileSelect:self];
}

- (IBAction)mapTypeControl:(UISegmentedControl *)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"selected_map_type"];
}


#pragma mark ---- UIPickerViewDataSource delegate methods ----

// returns the number of columns to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;  
}

#pragma mark ---- UIPickerViewDelegate delegate methods ----

// returns the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *driversList = [[NSUserDefaults standardUserDefaults] objectForKey:@"drivers_list"];
    return [driversList count];
}

// returns the title of each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *driversList = [[NSUserDefaults standardUserDefaults] objectForKey:@"drivers_list"];
    return [driversList objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // GETs the selected driver & SETs it into theUserDefaults
    NSString *driver = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"drivers_list"] objectAtIndex:row];
    [[NSUserDefaults standardUserDefaults]setObject:driver forKey:@"selected_driver"];
    NSLog(@"Driver -> %@", driver);
}


@end
