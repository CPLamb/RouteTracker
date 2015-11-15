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
@synthesize directoryContent = _directoryContent;
int filesCount = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
// loads data files onto the pickerView
//    [self loadPickerViewDataFiles];

    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
//  NSLog(@"SetupViewController viewWillAppear");

  self.magazineSelectorControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_spreadsheet"];
  
  self.mapSelectorControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_map_type"];
    
    // Gets the directoryContent before the view appears???
 //   [self TestButton:self.

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
//    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"selected_spreadsheet"];
    
    NSString *dataFilename = [[NSString alloc] init];
    switch(sender.selectedSegmentIndex) {
        case 0:
            dataFilename = @"SCWaveDistributionListCurrent";
            break;
        case 1:
            dataFilename = @"MontereyWaveDistributionList";
            break;
        case 2:
            dataFilename = @"EdibleMontereyDistributionList";
            break;
    }
    [[NSUserDefaults standardUserDefaults] setObject:dataFilename forKey:@"selected_spreadsheet"];
    
    NSLog(@"The selected spreadsheet is %@", dataFilename);
    
    [self.delegate dataFileSelect:self];
}

- (IBAction)mapTypeControl:(UISegmentedControl *)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"selected_map_type"];
}

- (void)loadUrlFromDocuments {
    NSLog(@"WTF - your work is done");
}

//- (void)loadPickerViewDataFiles {
//    int Count;
//    NSString *path;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    path = [paths objectAtIndex:0];
//    self.directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
//    for (Count = 0; Count < (int)[self.directoryContent count]; Count++)
//    {
//        NSLog(@"File %d: %@", Count, [self.directoryContent objectAtIndex:Count]);
//    }
//    filesCount = [self.directoryContent count];
//
//}

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
    NSArray *filesList = [[NSUserDefaults standardUserDefaults] objectForKey:@"downloaded_files"];
    return [filesList count];
    
//    NSArray *driversList = [[NSUserDefaults standardUserDefaults] objectForKey:@"drivers_list"];
//    return [driversList count];
}

// returns the title of each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *filesList = [[NSUserDefaults standardUserDefaults] objectForKey:@"downloaded_files"];
    return [filesList objectAtIndex:row];
    
//    NSArray *driversList = [[NSUserDefaults standardUserDefaults] objectForKey:@"drivers_list"];
//    return [driversList objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//  GETs the selected file
    NSString *file = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"downloaded_files"] objectAtIndex:row];
    NSLog(@"SetupVC - file selected -> %@", file);

    
    // use selected filename to load membersArray from documents directory
    [self loadUrlFromDocuments];
    // Alloc/init the fileURL outside the boundaries of switch/case statement
//    fileURL = [mainBundle URLForResource:dataFilename withExtension:@"plist"];

}


@end
