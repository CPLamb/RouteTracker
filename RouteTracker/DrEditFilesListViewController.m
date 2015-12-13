/* Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  DrEditFilesListViewController.m
//

#import "DrEditFilesListViewController.h"

#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"

#import "DrEditUtilities.h"

#import "FilesViewController.h"

// Constants used for OAuth 2.0 authorization.
static NSString *const kKeychainItemName = @"iOSDriveSample: Google Drive";
static NSString *const kClientId = @"853135828925-8t9bfsueorssgrv9jtqka6gq0o8vb4vr.apps.googleusercontent.com";
static NSString *const kClientSecret = @"F2CVzLCS5PQj2T4JazioSL8-";


@interface DrEditFilesListViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *authButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property (weak, readonly) GTLServiceDrive *driveService;
@property (retain) NSMutableArray *driveFiles;
@property BOOL isAuthorized;

@property (weak, nonatomic) GTLDriveFile *selectedSpreadsheet;

- (IBAction)authButtonClicked:(id)sender;
- (IBAction)refreshButtonClicked:(id)sender;

- (void)toggleActionButtons:(BOOL)enabled;
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;
- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth;
- (void)loadDriveFiles;
@end


@implementation DrEditFilesListViewController
@synthesize addButton = _addButton;
@synthesize authButton = _authButton;
@synthesize refreshButton = _refreshButton;
@synthesize driveFiles = _driveFiles;
@synthesize isAuthorized = _isAuthorized;

#pragma mark - Lifecycle Methods

- (void)awakeFromNib
{
  [super awakeFromNib];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Check for authorization.
  GTMOAuth2Authentication *auth =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientId
                                                      clientSecret:kClientSecret];
  if ([auth canAuthorize]) {
    [self isAuthorizedWithAuthentication:auth];
  }
}

- (void)viewDidUnload
{
  [self setAddButton:nil];
  [self setRefreshButton:nil];
  [self setAuthButton:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  // Sort Drive Files by modified date (descending order).
  [self.driveFiles sortUsingComparator:^NSComparisonResult(GTLDriveFile *lhs,
                                                           GTLDriveFile *rhs) {
    return [rhs.modifiedDate.date compare:lhs.modifiedDate.date];
  }];
  [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.driveFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

  GTLDriveFile *file = [self.driveFiles objectAtIndex:indexPath.row];
    cell.textLabel.text = file.title;
    [cell.textLabel sizeToFit];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"DrEditFilesListVC - Selected file at indexPath %ld %ld", indexPath.section, (long)indexPath.row);
    
    // Assigns proper file to spreadsheet
    self.selectedSpreadsheet = [self.driveFiles objectAtIndex:indexPath.row];
}

#pragma mark - Custom methods

// Creates a query to provide a list of files for display in a tableView
- (void)loadDriveFiles {
    
    //    GTLQueryDrive *query = [GTLQueryDrive queryForChildrenListWithFolderId:@"0B1p0HU9UyAkVamx2UGE5YmlSdDQ"];    // This is id of 00-CurrSprdsht
    //  GTLQueryDrive *query = [GTLQueryDrive queryForChildrenListWithFolderId:@"'00-CurrentSpreadsheets'"];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];            // Lists all file on the Drive
    //  GTLQueryDrive *query = [GTLQueryDrive queryForChildrenListWithFolderId:@"root"];
    
    //  query.q = @"title = '00-CurrentSpreadsheets'";
    //   query.q = @"'root' in parents and trashed=false";
    //   query.q = [NSString stringWithFormat:@"'00-CurrentSpreadsheets' IN parents"];
    //      query.q = @"id = '0B1p0HU9UyAkVamx2UGE5YmlSdDQ'";      // filez in folder=ID
    //   query.q = @"mimeType = 'application/vnd.google-apps.folder'";      // display folders ONLY
    //   query.q = @"mimeType = 'text/plain'";      // display text files ONLY
    query.q = @"mimeType = 'application/vnd.google-apps.spreadsheet'";      // display spreadsheets
    
    UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading files"
                                                             delegate:self];
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFileList *files,
                                                              NSError *error) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (error == nil) {
            if (self.driveFiles == nil) {
                self.driveFiles = [[NSMutableArray alloc] init];
            }
            [self.driveFiles removeAllObjects];
            [self.driveFiles addObjectsFromArray:files.items];
            //       NSLog(@"filesList = %@", files.items.description);
            [self.tableView reloadData];
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load files"
                                               message:[error description]
                                              delegate:self];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  FilesViewController *viewController = [segue destinationViewController];
  NSString *segueIdentifier = segue.identifier;
//  viewController.driveService = [self driveService];
//  viewController.delegate = self;
  
  if ([segueIdentifier isEqualToString:@"editFile"]) {                  // tap a cell
      
//      NSLog(@"DrEditFilesListVC selcted file = %@", self.selectedSpreadsheet);
      viewController.selectedFile = self.selectedSpreadsheet;
      viewController.driveService = [self driveService];
  } else if ([segueIdentifier isEqualToString:@"addFile"]) {    // tap add button
//    viewController.selectedFile = [GTLDriveFile object];
//    viewController.fileIndex = -1;
  }
}

// delegate method
- (NSInteger)didUpdateFileWithIndex:(NSInteger)index
                          driveFile:(GTLDriveFile *)driveFile {
  if (index == -1) {
    if (driveFile != nil) {
      // New file inserted.
      [self.driveFiles insertObject:driveFile atIndex:0];
      index = 0;
    }
  } else {
    if (driveFile != nil) {
      // File has been updated.
      [self.driveFiles replaceObjectAtIndex:index withObject:driveFile];
    } else {
      // File has been deleted.
      [self.driveFiles removeObjectAtIndex:index];
      index = -1;
    }
  }
  return index;  
}

- (GTLServiceDrive *)driveService {
  static GTLServiceDrive *service = nil;
  
  if (!service) {
    service = [[GTLServiceDrive alloc] init];
    
    // Have the service object set tickets to fetch consecutive pages
    // of the feed so we do not need to manually fetch them.
    service.shouldFetchNextPages = YES;
    
    // Have the service object set tickets to retry temporary error conditions
    // automatically.
    service.retryEnabled = YES;
  }
  return service;
}

- (IBAction)authButtonClicked:(id)sender {
  if (!self.isAuthorized) {
      NSLog(@"SIGNing IN!");
    // Sign in.
    SEL finishedSelector = @selector(viewController:finishedWithAuth:error:);
    GTMOAuth2ViewControllerTouch *authViewController = 
      [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive  // kGTLAuthScopeDriveFile
                                                 clientID:kClientId
                                             clientSecret:kClientSecret
                                         keychainItemName:kKeychainItemName
                                                 delegate:self
                                         finishedSelector:finishedSelector];
      [self presentViewController:authViewController
                         animated:YES
                       completion:nil];

  } else {
    // Sign out
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    [[self driveService] setAuthorizer:nil];
    self.authButton.title = @"Sign in";
    self.isAuthorized = NO;
    [self toggleActionButtons:NO];
    [self.driveFiles removeAllObjects];
    [self.tableView reloadData];
  }  
}

- (IBAction)refreshButtonClicked:(id)sender {
    NSLog(@"Refresh me PLEASE!");
  [self loadDriveFiles];
}

- (void)toggleActionButtons:(BOOL)enabled {
  self.addButton.enabled = enabled;
  self.refreshButton.enabled = enabled;
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
    if (error == nil) {
        [self isAuthorizedWithAuthentication:auth];

    }
}

- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
  [[self driveService] setAuthorizer:auth];
  self.authButton.title = @"Sign out";
  self.isAuthorized = YES;
  [self toggleActionButtons:YES];
  [self loadDriveFiles];
}

@end
