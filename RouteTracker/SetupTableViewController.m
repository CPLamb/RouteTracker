//
//  SetupTableViewController.m
//  RouteTracker
//
//  Created by Chris Lamb on 12/29/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import "SetupTableViewController.h"

@import MessageUI;

// This needs to be an NSArray of email addresses
#define EMAILID01 @"guna.iosdev@gmail.com"
#define   EMAILID02 @"cplamb@pacbell.net"

@interface SetupTableViewController ()<MFMailComposeViewControllerDelegate>
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
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self hardcodedListWhenFirstLaunchOrClearList];
    [self.filePicker reloadAllComponents];
    
    //  NSLog(@"SetupViewController viewWillAppear");
    
    //  self.magazineSelectorControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_spreadsheet"];
    
    self.mapSelectorControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_map_type"];
    
    // Gets the directoryContent before the view appears???
    //   [self TestButton:self.
    
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
    
    NSArray *toRecipients	= [NSArray arrayWithObjects:EMAILID01, EMAILID02, nil];
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
#warning check here later
    NSString *file = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"downloaded_files"] objectAtIndex:row];
    NSLog(@"SetupVC - file selected -> %@", file);
    
    [[NSUserDefaults standardUserDefaults] setObject:file forKey:@"selected_photo"];
    [[NSUserDefaults standardUserDefaults] setObject:file forKey:@"selected_plist"];
    // use selected filename to load membersArray from documents directory
    [self loadUrlFromDocuments];
    
}


@end