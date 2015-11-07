//
//  FilesViewController.m
//  RouteTracker
//
//  Created by Chris Lamb on 1/4/15.
//  Copyright (c) 2015 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import "FilesViewController.h"

#import "DrEditUtilities.h"

@interface FilesViewController ()

- (IBAction)downloadButton:(UIButton *)sender;
- (IBAction)updateListButton:(UIButton *)sender;
- (IBAction)changeFolderButton:(UIButton *)sender;

@end

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
  self.filenameLabel.text = [NSString stringWithFormat:@"Filename: %@", fileTitle];
  self.modifiedDateTextfield.text = [self.selectedFile.modifiedDate stringValue];
  NSLog(@"FilesVC - Selected file %@", self.selectedFile);
}

- (IBAction)downloadButton:(UIButton *)sender
{
  NSLog(@"Let's try to download a file from Google Drive");
  [self loadFileContent];

  //    int spreadsheetNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_spreadsheet"];
  //    NSLog(@"spreadsheet is %d", spreadsheetNumber);
}

- (IBAction)updateListButton:(UIButton *)sender;
{
  NSLog(@"Copies downloaded file into NSUserDefaults and overwrites the local list");
}

- (IBAction)changeFolderButton:(UIButton *)sender
{
  NSLog(@"Let's try to change the Google Drive folder");
}

#pragma mark - Google Drive methods

- (void)loadFileContent {
  // NSLog(@"GONNA TRY n LOAD this files content= %@", self.selectedFile);

  UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading file content"
                                                           delegate:self];

  // Trying to access spreadsheet files using exportLinks metadata Query for the strings
  GTLDriveFileExportLinks *myExportLinks = self.selectedFile.exportLinks;

  NSString *spreadsheetURL = [[myExportLinks additionalProperties]objectForKey:@"text/csv"];
  NSLog(@"The export LINKS %@", myExportLinks);
  NSLog(@"Additional Properties : %@", [myExportLinks additionalProperties]);
  NSLog(@"-----------------------");
  NSLog(@"AND the WINNING URL is = %@", spreadsheetURL);
  if (spreadsheetURL) {
    GTMHTTPFetcher *fetcher = [self.driveService.fetcherService fetcherWithURLString:spreadsheetURL];
    //    [self.driveService.fetcherService fetcherWithURLString:self.selectedFile.downloadUrl];
    NSLog(@"Drive Service = %@",self.driveService);
    NSLog(@"Fetcher Service = %@",self.driveService.fetcherService);
    NSLog(@"Fetcher = %@",fetcher);
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
      [alert dismissWithClickedButtonIndex:0 animated:YES];
      if (error == nil) {
        NSLog(@"FilesVC - It loaded something");
        fileContent = [[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding];

        self.fileContent.text = fileContent;

        self.membersArray = [self csvDataToArrayOfDictionaries:fileContent]; // convert to plist

        NSLog(@"FilesVC loadFileContent - self.membersArray = \n%@", self.membersArray);

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
      NSLog(@"FilesVC csvDataToArrayOfDictionaries: - The string we're looking at is \n>>>>%@<<<<", csvFile);

//  NSString *csvString = csvFile;

  // Build tokens array from string

  NSUInteger stringLength = [csvFile length];
  //  NSLog(@"String length = %lu", stringLength);

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

    //    NSLog(@"Character[%d] =  %@ unicode = %d", charIndex, tokenChar, [csvString characterAtIndex:charIndex]);


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

      tokenWord = @""; // reset tokenWord
      charIndex++; // skip over carriage return
      continue; //  skip linefeed
    }
    // Build tokenWord tokenChar-by-tokenChar
    tokenWord = [tokenWord stringByAppendingString:tokenChar];
  } // for loop

  // grab the current tokenWord and add to tokens array. Note this is the last token in the file.
  tokens[tokenCount] = tokenWord;

  // Parsing is complete

  NSLog(@"tokenCount = %d", tokenCount);

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

    }

    plistData = [plistData stringByAppendingString:@"\t</dict>\n"];

  } // return for-loop over entire data set

  plistData = [plistData stringByAppendingString:@"</array>\n"];
  plistData = [plistData stringByAppendingString:@"</plist>\n"];

// The pList is complete
  NSLog(@"FilesVC csvDataToArrayOfDictionaries -- plistData\n\n%@", plistData);


// Create an array of dictionaries

  // create an empty membersArray
  NSMutableArray *membersArray = [[NSMutableArray alloc]init];

  // create empty dictionary
  NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc]init];

  // loop over entire data set
  for(int tokenIndex=numberOfFields; tokenIndex < tokenCount; tokenIndex += numberOfFields){
        [currentDictionary removeAllObjects];
    // loop over fields
    for(int i = 0; i < numberOfFields; i++){
       // Adds given key-value pair to the dictionary.
      [currentDictionary setValue:tokens[i + tokenIndex] forKey:tokens[i]];
    }


    // Add dictionary to membersArray
    [membersArray addObject:currentDictionary];
  }

  NSLog(@"FilesVC csvDataToArrayOfDictionaries -- membersArray = \n%@", membersArray);

  return membersArray;
}
@end
