//
//  SetupTableViewController.m
//  RouteTracker
//
//  Created by Chris Lamb on 12/29/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import "SetupTableViewController.h"
#import "HomeViewController.h"

@import MessageUI;

// This needs to be an NSArray of email addresses
// #define EMAILID01 @"guna.iosdev@gmail.com"       // temp fix CPL
#define   EMAILID02 @"cplamb@pacbell.net"

@interface SetupTableViewController ()<MFMailComposeViewControllerDelegate, UITextFieldDelegate>
@property NSArray *driverList;

- (IBAction)selectSpreadsheetControl:(UISegmentedControl *)sender;

@end

@implementation SetupTableViewController

@synthesize delegate = _delegate;
@synthesize directoryContent = _directoryContent;
NSUInteger filesCount = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // loads data files onto the pickerView
    [self loadPickerViewDataFiles];
    
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newSearchFromList:) name:kListTableStartNewSearchNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listFilterChange) name:kListSearchFilterChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterDetail) name:kListTableStartNewSearchNotification object:nil];

    _routerContent = [NSArray new];
    

}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self hardcodedListWhenFirstLaunchOrClearList];
    
    //  NSLog(@"SetupViewController viewWillAppear");
    
    //  self.magazineSelectorControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_spreadsheet"];
    
    self.mapSelectorControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_map_type"];
    
    // Gets the directoryContent before the view appears???
    //   [self TestButton:self.
    
    if ([_routerPicker selectedRowInComponent:0] == 0) {
        [self calculateTotals:[self selectProperPlistData]];
    }
    
    [self.filePicker reloadAllComponents];
    
    NSString *filename = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];
    if (filename) {
        NSArray *filesList = [[NSUserDefaults standardUserDefaults] objectForKey:@"downloaded_files"];
        if (filesList && filesList.count > 0) {
            NSInteger index = [filesList indexOfObject:filename];
            if (index <= filesCount) {
                [self.filePicker selectRow:index inComponent:0 animated:YES];
                [self.filePicker.delegate pickerView:self.filePicker didSelectRow:index inComponent:0];
            }
        }
    } else {
        [self.filePicker selectRow:0 inComponent:0 animated:YES];
        [self.filePicker.delegate pickerView:self.filePicker didSelectRow:0 inComponent:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //   NSLog(@"view WILL Disappear, used to change the spreadsheet");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods

- (void)enterDetail {
}

- (void)listFilterChange {
    [_routerPicker selectRow:0 inComponent:0 animated:false];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.copiesBoxBundle) {
        int v = textField.text.intValue;
        if (v != 0) {
            [[NSUserDefaults standardUserDefaults] setInteger:v forKey:@"copies_bundle"];
            [self calculateTotals:[self selectProperPlistData]];
        }
    }
    
    return [textField resignFirstResponder];
}

- (void)newSearchFromList: (NSNotification *)notification {
    if (notification.object) {
        _searchString = notification.object;
        self.routeSelectedLabel.text = _searchString;
    }
    
    if (_searchString.length <= 0) {
        self.routeSelectedLabel.text = @"All";
    }
}

- (void)hardcodedListWhenFirstLaunchOrClearList {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryContent = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    if (directoryContent.count <= 0) {
        NSString *hardcodedFilePath = [[NSBundle mainBundle] pathForResource:@"EdibleMontereyDistributionList" ofType:@"plist"];
        NSError *error = nil;
        NSString *copyPath = [NSString stringWithFormat:@"%@/%@", path, @"EdibleMontereyDistributionListDefault"];
        if([fileManager copyItemAtPath:hardcodedFilePath toPath:copyPath error:&error]==NO){
            NSLog(@"error = %@", error);
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:@[@"EdibleMontereyDistributionList"]
                                                  forKey:@"downloaded_files"];
    }
}

- (NSArray *)calculateTotals:(NSArray *)array
{
    NSInteger stops = [array count];
    NSInteger copies = 0;
    NSInteger bundles = 0;
    NSInteger returns = 0;
    
    // loop thru the array & total values
    for (int i=0;i<=stops-1;i++) {
        copies = copies + [[[array objectAtIndex:i] valueForKey:@"Total Quantity to Deliver"] integerValue];
        returns = returns + [[[array objectAtIndex:i] valueForKey:@"Returns"] integerValue];
    }
//    NSInteger v = [[NSUserDefaults standardUserDefaults] integerForKey:@"copies_bundle"];
    NSInteger v = 50;   // temp fix CPL for initialization problem
    bundles = copies/v;
    _stopTextField.text = [NSString stringWithFormat:@"%ld", stops];
    _returnTextField.text = [NSString stringWithFormat:@"%ld", returns];
    _copiesTextField.text = [NSString stringWithFormat:@"%ld", copies];
    _bundleTextField.text = [NSString stringWithFormat:@"%ld", bundles];
    
    return @[_stopTextField.text, _returnTextField.text, _copiesTextField.text, _bundleTextField.text];
}

#pragma mark - new home ui caculator
- (NSArray *)selectProperPlistData {
    
    
    NSString *myFilename = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];
    
    // Alloc/init the fileURL outside the boundaries of switch/case statement
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.memberData loadPlistData];
    
    NSArray *array = [NSArray arrayWithArray:delegate.memberData.membersArray];
    
    NSLog(@"HomeVC -- selectProper pList -- Loads fileName %@", myFilename);
    if (_searchString != nil && _searchString.length > 0) {
        NSLog(@"Before filter has %ld count", array.count);
        NSMutableArray *filterArray = [NSMutableArray new];
        
        for (int i=0; i<+[array count]-1; i++) {
            NSString *searchName = [[array objectAtIndex:i] objectForKey:@"Name"];
            NSString *searchDriver = [[array objectAtIndex:i] objectForKey:@"Driver"];
            NSString *searchCategory = [[array objectAtIndex:i] objectForKey:@"Category"];
            
            BOOL foundInName = [searchName rangeOfString:_searchString options:NSCaseInsensitiveSearch].location == NSNotFound;
            BOOL foundInDriver = [searchDriver rangeOfString:_searchString options:NSCaseInsensitiveSearch].location == NSNotFound;
            BOOL foundInCategory = [searchCategory rangeOfString:_searchString options:NSCaseInsensitiveSearch].location == NSNotFound;
            if (!foundInName || !foundInDriver || !foundInCategory) {
                [filterArray addObject:[array objectAtIndex:i]];
            }
        }
        
        NSLog(@"after filter has %ld count", filterArray.count);
        _searchString = nil;
        
        return [NSArray arrayWithArray:filterArray];
    } else {
        return array;
    }
}

- (IBAction)uploadToGoogleButtonPressed:(id)sender {
    
    MFMailComposeViewController *emailVC = [[MFMailComposeViewController alloc] init];
    
    emailVC.mailComposeDelegate = self;
    
    [emailVC setSubject:@"Updated Distribution list"];
    
    NSString *filename = [[NSUserDefaults standardUserDefaults] stringForKey:@"updated_plist"];
    
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:filename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSLog(@"We couldn't find the file, there are no changes to upload");
        
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Upload Error"
                                           message:@"There is no updates to email"
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    NSData *updatedPlistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
//    NSMutableArray *toRecipients	= [NSMutableArray arrayWithObjects:EMAILID01, EMAILID02, nil];
    NSMutableArray *toRecipients	= [NSMutableArray arrayWithObjects:EMAILID02, nil]; // temp fix CPL
    
    if (_uploadEmailTextField.text.length > 0) {
        [toRecipients addObject:_uploadEmailTextField.text];
    }
    if (_upload2EmailTextField.text.length > 0) {
        [toRecipients addObject:_upload2EmailTextField.text];
    }
    
    [emailVC setToRecipients:toRecipients];
    
    [emailVC addAttachmentData:updatedPlistXML mimeType:@"text/xml" fileName:filename];
    //   [emailVC addAttachmentData:updatedPlistXML mimeType:@"text/xml" fileName:plistPath];
    
    // Fill out the email body text
    NSString *emailBody = @"Attached updated distribution plist file";
    [emailVC setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:emailVC animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;
            [delegate.arrayToBeUploaded removeAllObjects];
            NSString *filename = [[NSUserDefaults standardUserDefaults] stringForKey:@"updated_plist"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error]){
                NSLog(@"Error deleting modifiedPlist file");
            }
        }
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [controller dismissViewControllerAnimated:YES completion:nil];
}


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
    
    NSString *selectedFile = [[NSUserDefaults standardUserDefaults] objectForKey:@"selected_plist"];
    
    NSLog(@"Takes %@ from the pickerView selection and uploads it into the memberListData array", selectedFile);
    
    //    NSString *path;
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    path = [paths objectAtIndex:0];
    //    path = [path stringByAppendingPathComponent:selectedFile];
    //    NSData *theData;
    //    theData = [[NSFileManager defaultManager] contentsAtPath:path];
    //    NSString *theDataString = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    //    NSLog(@"TheData = %@", theDataString);
    
    // Now goes to the Data model MemberListData and does the actual plist to array conversion
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.memberData loadPlistData];
}

- (void)loadPickerViewDataFiles {
    int Count;
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    self.directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (Count = 0; Count < (int)[self.directoryContent count]; Count++)
    {
        NSLog(@"File %d: %@", Count, [self.directoryContent objectAtIndex:Count]);
    }
    filesCount = [self.directoryContent count];
    
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
    if (_filePicker == pickerView) {
        NSArray *filesList = [[NSUserDefaults standardUserDefaults] objectForKey:@"downloaded_files"];
        return [filesList count];
    } else {
        return [_routerContent count] + 1;
    }
    
    //    NSArray *driversList = [[NSUserDefaults standardUserDefaults] objectForKey:@"drivers_list"];
    //    return [driversList count];
}

// returns the title of each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_filePicker == pickerView) {
        NSArray *filesList = [[NSUserDefaults standardUserDefaults] objectForKey:@"downloaded_files"];
        return [filesList objectAtIndex:row];
    } else {
        if (row == 0) {
            return @"All";
        } else {
            return _routerContent[row-1];
        }
    }
    
    //    NSArray *driversList = [[NSUserDefaults standardUserDefaults] objectForKey:@"drivers_list"];
    //    return [driversList objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSMutableArray *calculates;
    //  GETs the selected file
    if (_filePicker == pickerView) {
        NSString *file = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"downloaded_files"] objectAtIndex:row];
        NSLog(@"SetupVC - file selected -> %@", file);
        
        _currentListSelected.text = file;
        [[NSUserDefaults standardUserDefaults] setObject:file forKey:@"selected_photo"];
        [[NSUserDefaults standardUserDefaults] setObject:file forKey:@"selected_plist"];
        // use selected filename to load membersArray from documents directory
        [self loadUrlFromDocuments];
        
        [self caculatorRouterPicker];
        
        calculates = [NSMutableArray arrayWithArray:
                                      [self calculateTotals:[self selectProperPlistData]]];
        [calculates addObject:_routeSelectedLabel.text];
        
        [self.routerPicker reloadAllComponents];
        
        NSString *routeSelected = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedDriver"];
        if (routeSelected) {
            if (![self.routerContent containsObject:routeSelected]) {
                [self.routerPicker selectRow:0 inComponent:0 animated:YES];
                return [self.routerPicker.delegate pickerView:self.routerPicker didSelectRow:0 inComponent:0];
            }
            NSInteger index = [self.routerContent indexOfObject:routeSelected];
            if (index+1 <= self.routerContent.count) {
                [self.routerPicker selectRow:index+1 inComponent:0 animated:YES];
                [self.routerPicker.delegate pickerView:self.routerPicker didSelectRow:index+1 inComponent:0];
            }
        } else {
            if (self.routerContent && self.routerContent.count > 0) {
                [self.routerPicker selectRow:0 inComponent:0 animated:YES];
                [self.routerPicker.delegate pickerView:self.routerPicker didSelectRow:0 inComponent:0];
            }
        }
    } else {
        if (row == 0) {
            _routeSelectedLabel.text = @"All";
            _searchString = @"";
        } else {
            _searchString = _routerContent[row-1];
            _routeSelectedLabel.text = _routerContent[row-1];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:self.routeSelectedLabel.text forKey:@"SelectedDriver"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        calculates = [NSMutableArray arrayWithArray:
                               [self calculateTotals:[self selectProperPlistData]]];
        [calculates addObject:_routeSelectedLabel.text];
    }
    NSArray *notfiArr = [NSArray arrayWithArray:calculates];
    [[NSUserDefaults standardUserDefaults] setObject:notfiArr forKey:@"TotalStats"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRouterPickerValueChangeNotification object: notfiArr];
}

- (void)caculatorRouterPicker {
    NSArray *arr = [self selectProperPlistData];
    NSMutableSet *set = [NSMutableSet new];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [set addObject:obj[@"Name"]];
        [set addObject:obj[@"Driver"]];  // temp fix CPL
    }];

    _routerContent = [set allObjects];
    [_routerPicker reloadAllComponents];
}

@end
