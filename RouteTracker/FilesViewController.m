//
//  FilesViewController.m
//  RouteTracker
//
//  Created by Chris Lamb on 1/4/15.
//  Copyright (c) 2015 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import "FilesViewController.h"
#import "AppDelegate.h"
#import "MemberListData.h"
#import "DrEditUtilities.h"

@implementation FilesViewController
NSString* fileContent;
@synthesize driveService = _driveService;
@synthesize selectedFile = _selectedFile;
@synthesize delegate = _delegate;

#pragma mark - Lifecycle methods

- (void)viewDidLoad {
  [super viewDidLoad];

  // Displays info about the selected file
  self.fileContent.delegate = self;

  [self displayFileName];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Custom RouteTracker methods

- (void)displayFileName
{
  NSString *fileTitle = self.selectedFile.title;
  self.filenameLabel.text = fileTitle;
  self.modifiedDateTextfield.text = [self.selectedFile.modifiedDate stringValue];
    NSLog(@"FilesVC - Selected file %@", self.selectedFile.title);
}

- (IBAction)downloadSpreadsheetButton:(UIButton *)sender
{
  NSLog(@"Let's try to download a file from Google Drive");
  [self loadFileContent];

  //    int spreadsheetNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_spreadsheet"];
  //    NSLog(@"spreadsheet is %d", spreadsheetNumber);
}

- (IBAction)saveSpreadsheetButton:(UIButton *)sender
{
    NSLog(@"Overwrites the local list & then reloads the file");
    
// reloads the file that is selected ***This may not be necessary****
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.memberData loadPlistData];
}

- (IBAction)testButton:(UIButton *)sender // for testing file management stuff
{
    NSLog(@"01 test action - READS a file from the Documents directory");

    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:self.filenameLabel.text];
    NSData *theData;
    theData = [[NSFileManager defaultManager] contentsAtPath:path];
    NSString *theDataString = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    NSLog(@"TheData = %@", theDataString);
}

- (IBAction)test02Button:(UIButton *)sender {
    NSLog(@"02 test action - SAVES a file to Documents directory");
    NSData *file = [self.fileContent.text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:self.filenameLabel.text];
    NSLog(@"Path/FilenName = %@", path);
    
    [[NSFileManager defaultManager] createFileAtPath:path
                                            contents:file
                                          attributes:nil];
}

- (IBAction)test03Button:(UIButton *)sender {
    NSLog(@"03 test action - LIST all files in directory");
    
    //----- LIST ALL FILES -----
    NSLog(@"LISTING ALL FILES FOUND");
    
    int Count;
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (Count = 0; Count < (int)[directoryContent count]; Count++)
    {
        NSLog(@"File %d: %@", (Count + 1), [directoryContent objectAtIndex:Count]);
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:directoryContent
                                              forKey:@"downloaded_files"];
 }

- (IBAction)test04Button:(UIButton *)sender {
    NSLog(@"04 test action - DELETES all files in the directory");

//DELETE ALL FILES IN DIRECTORY
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSError *error = nil;
    if (error == nil)
    {
        for (NSString *Filename in directoryContent)
        {
            NSString *FilePath = [path stringByAppendingPathComponent:Filename];
            BOOL removeSuccess = [[NSFileManager defaultManager] removeItemAtPath:FilePath error:&error];
            if (!removeSuccess)
            {
                // Error handling
            }
        }
    }
}

- (IBAction)test05Button:(UIButton *)sender {
    NSLog(@"READS the formatted plist file & checks to see if it can be converted into an array (of dictionaries)");
    
    NSError *errorDescr = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileTitle = self.selectedFile.title;
    plistPath = [rootPath stringByAppendingPathComponent:fileTitle];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSLog(@"We couldn't find the file");
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSArray *temp = (NSArray *)[NSPropertyListSerialization propertyListWithData:plistXML
                                                        options:kCFPropertyListXMLFormat_v1_0
                                                        format:kCFPropertyListImmutable
                                                        error:&errorDescr];

    if (!temp) {
        NSLog(@"Error reading plist: %@, format %lu", errorDescr, (unsigned long)format);
    }
// Check to see if file is format properly
    BOOL goodFile = [NSPropertyListSerialization propertyList:plistXML isValidForFormat:kCFPropertyListXMLFormat_v1_0];
    NSLog(@"File is %d", goodFile);
    
    NSLog(@"Took no time at all! %@", [temp objectAtIndex:[temp count]-1]);
}

#pragma mark - Google Drive methods

- (void)loadFileContent {
  // NSLog(@"GONNA TRY n LOAD this files content= %@", self.selectedFile);

  UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading file content"
                                                           delegate:self];

  // Trying to access spreadsheet files using exportLinks metadata Query for the strings
  GTLDriveFileExportLinks *myExportLinks = self.selectedFile.exportLinks;

  NSString *spreadsheetURL = [[myExportLinks additionalProperties]objectForKey:@"text/csv"];
//  NSLog(@"The export LINKS %@", myExportLinks);
//  NSLog(@"Additional Properties : %@", [myExportLinks additionalProperties]);
//  NSLog(@"-----------------------");
//  NSLog(@"AND the WINNING URL is = %@", spreadsheetURL);
    
  if (spreadsheetURL) {
    GTMHTTPFetcher *fetcher = [self.driveService.fetcherService fetcherWithURLString:spreadsheetURL];
    //    [self.driveService.fetcherService fetcherWithURLString:self.selectedFile.downloadUrl];
//    NSLog(@"Drive Service = %@",self.driveService);
//    NSLog(@"Fetcher Service = %@",self.driveService.fetcherService);
//    NSLog(@"Fetcher = %@",fetcher);
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
      [alert dismissWithClickedButtonIndex:0 animated:YES];
      if (error == nil) {
        NSLog(@"FilesVC - It loaded something");
        fileContent = [[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding];

        self.fileContent.text = fileContent;

        self.membersArray = [self csvDataToArrayOfDictionaries:fileContent]; // convert to plist

          self.numberOfRowsTextfield.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.membersArray count]];
          
//        NSLog(@"FilesVC loadFileContent - self.membersArray = \n%@", self.membersArray);

      } else {
        NSLog(@"An error occurred: %@", error);
        [DrEditUtilities showErrorMessageWithTitle:@"Unable to load file"
                                           message:[error description]
                                          delegate:self];
      }
    }];
  }
}


// fileContent is the variable displaying loaded data on the file loaded screen

// http://www.raywenderlich.com/66395/documenting-in-xcode-with-headerdoc-tutorial
/*!
 * @discussion This method accepts a Google spreadsheet formated as a csv text string and returns an Array of Dictionaries
 * @param
 */
- (NSArray*)csvDataToArrayOfDictionaries: (NSString *) csvFile {
      NSLog(@"FilesVC csvDataToArrayOfDictionaries: - The string we're looking at is \n\n\n>>>>%@<<<<\n\n", csvFile);

  NSString *csvString = csvFile;

  // Build tokens array from string

  NSUInteger stringLength = [csvFile length];

// initialization
    NSString *tokenWord = @"";
  NSMutableArray *tokens = [[NSMutableArray alloc]init];
  int tokenCount = 0;
  bool insideQuote = false;
  bool ignoreComma = false;
  NSString *plistData = [[NSString alloc]init];
  int numberOfFields = 0;

  // constants
  int commaSentinel = 44;
  int quoteSentinel = 34;
  int linefeedSentinel = 10;
  int carriageReturnSentinel = 13;

  // loop over string to break-out tokens
  for(int charIndex = 0; charIndex < stringLength; charIndex++) {

    // read csvString current character and convert to NSString *tokenChar
    NSString *tokenChar = [NSString stringWithFormat:@"%c", [csvFile characterAtIndex: charIndex ]];
      
#pragma mark TODO - add IF statement to insert blank char[32?] where field in nill
    NSLog(@"Character[%d] =  %@ unicode = %d", charIndex, tokenChar, [csvString characterAtIndex:charIndex]);

    // look for quote
    if ([csvFile characterAtIndex:charIndex] == quoteSentinel) {
      if (insideQuote == true) {
        insideQuote = false; // closing quote
        ignoreComma = false;
        continue;

      } else {
        ignoreComma = true;
        insideQuote = true; // opening quote
        continue;
      }
    }
    // look for comma & ignore comma if inside quote
    if ([csvFile characterAtIndex:charIndex] == commaSentinel && !ignoreComma) {
      tokens[tokenCount] = tokenWord; // grab the current tokenWord and add to tokens array
      //      NSLog(@"tokens[%d] = %@", tokenCount, tokenWord);
      tokenCount++;
      tokenWord = @""; // reset tokenWord
      continue;
    }
      
    // look for end-of-line i.e., a carriageReturn followed by linefeed
    if (([csvFile characterAtIndex:charIndex] == carriageReturnSentinel)
        && ([csvFile characterAtIndex:charIndex+1] == linefeedSentinel)) {

      // grab the current tokenWord and add to tokens array. Note, this is the last token on the current line
      tokens[tokenCount] = tokenWord;

      //      NSLog(@"tokens[%d] = %@", tokenCount, tokenWord);
      tokenCount++;

      // numberOfFields is the number of keys in the spreadsheet. This line of code executes
      // once following the first time  a carriage return & line feed is detected.
      if (numberOfFields == 0) numberOfFields = tokenCount;

      tokenWord = @" "; // reset tokenWord
      charIndex++; // skip over carriage return
      continue; //  skip linefeed
    }
    // Build tokenWord tokenChar-by-tokenChar
    tokenWord = [tokenWord stringByAppendingString:tokenChar];
      NSLog(@"tokenWord = %@", tokenWord);

  } // for loop
    if ([tokenWord length] == 0) {
        NSLog(@"Hah! we found an empty word %@", tokenWord);
        tokenWord = @" ";
    }
 
  // grab the current tokenWord and add to tokens array. Note this is the last token in the file.
  tokens[tokenCount] = tokenWord;
    
  // Parsing is complete

  NSLog(@"tokenCount = %d", tokenCount);
//    NSLog(@"tokens array = %@", tokens);

// Build plist string in pieces
  plistData = [plistData stringByAppendingString:@"\n\n\n<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
  plistData = [plistData stringByAppendingString:@"\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"];
  plistData = [plistData stringByAppendingString:@"\n<plist version=\"1.0\">"];
  plistData = [plistData stringByAppendingString:@"\n<array>\n"];

  // loop over entire data set
  for(int tokenIndex=numberOfFields; tokenIndex < tokenCount; tokenIndex += numberOfFields){

    // create a dictionary entry
    plistData = [plistData stringByAppendingString:@"\t<dict>\n"];

    for(int i = 0; i < numberOfFields; i++){

      // key
      plistData = [plistData stringByAppendingString:@"\t\t<key>"];
      plistData = [plistData stringByAppendingString:tokens[i]];
      plistData = [plistData stringByAppendingString:@"</key>\n"];

      // value
      plistData = [plistData stringByAppendingString:@"\t\t<string>"];
      plistData = [plistData stringByAppendingString:tokens[i + tokenIndex]];
      plistData = [plistData stringByAppendingString:@"</string>\n"];
//        NSLog(@"Token %d   = key %@ value %@", ((i+1)+(tokenIndex-12)), tokens[i], tokens[i + tokenIndex]);
    }

    plistData = [plistData stringByAppendingString:@"\t</dict>\n"];

  } // return for-loop over entire data set

    plistData = [plistData stringByAppendingString:@"</array>\n"];
  plistData = [plistData stringByAppendingString:@"</plist>\n"];

// The pList is complete
//  NSLog(@"FilesVC csvDataToArrayOfDictionaries -- PLISTDATA\n\n%@", plistData);

    
// CPL - SAVES the file to the documents directory
//    NSData *file = [plistData dataUsingEncoding:NSUTF8StringEncoding];
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:self.filenameLabel.text];
//    NSLog(@"Path/FilenName = %@", path);
    
    BOOL fileConverted = [plistData writeToFile:path atomically:YES];
    NSLog(@"%@", @(fileConverted));
    
//    [[NSFileManager defaultManager] createFileAtPath:path
//                                            contents:file
//                                          attributes:nil];

// Create an array of dictionaries

  // create an empty membersArray
  NSMutableArray *membersArray = [[NSMutableArray alloc]init];

  // loop over entire data set
  for(int tokenIndex=numberOfFields; tokenIndex < tokenCount; tokenIndex += numberOfFields){

    // create empty dictionary
    NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc]init];

    // loop over fields
    for(int i = 0; i < numberOfFields; i++){
       // Adds given key-value pair to the dictionary.
      [currentDictionary setValue:tokens[i + tokenIndex] forKey:tokens[i]];
    }

    // Add dictionary to membersArray
    [membersArray addObject:currentDictionary];
  }

//  NSLog(@"FilesVC csvDataToArrayOfDictionaries -- membersArray = \n%@", membersArray);

  AppDelegate *delegate = [UIApplication sharedApplication].delegate;
  [delegate.memberData loadPlistData];
//  NSLog(@"FilesVC -- Should reload the dataFile %@", delegate.memberData.description);

  return membersArray;
}

@end
