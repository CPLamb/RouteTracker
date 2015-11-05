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

                [self csvToPlist]; // convert to plist

            } else {
                NSLog(@"An error occurred: %@", error);
                [DrEditUtilities showErrorMessageWithTitle:@"Unable to load file"
                                                   message:[error description]
                                                  delegate:self];
            }
        }];
    }
}

// convert to plist
- (void)csvToPlist {
    NSLog(@"FilesVC - The string we're looking at is \n>>>>%@<<<<", self.fileContent.text);

    NSString *csvString = self.fileContent.text;

// Build tokens array from string

  NSUInteger stringLength = [csvString length];
  NSLog(@"String length = %lu", stringLength);

  // initialization
  NSString *tokenWord = @"";
  NSMutableArray *tokens;
  int tokenCount = 0;
  bool insideQuote = false;
  bool ignoreComma = false;

  // constants
  int commaSentinel = 44;
  int quoteSentinel = 34;
  int linefeedSentinel = 10;
  int carriageReturnSentinel = 13;

  // loop over string to break-out tokens
  for(int charIndex = 0; charIndex < stringLength; charIndex++) {

    // read csvString current character and convert to NSString *tokenChar
    NSString *tokenChar = [NSString stringWithFormat:@"%c", [csvString characterAtIndex: charIndex ]];

//    NSLog(@"Character[%d] =  %@ unicode = %d", charIndex, tokenChar, [csvString characterAtIndex:charIndex]);


    // look for quote
    if ([csvString characterAtIndex:charIndex] == quoteSentinel) {
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
    if ([csvString characterAtIndex:charIndex] == commaSentinel && !ignoreComma) {
      tokens[tokenCount] = tokenWord; // grab the current tokenWord and add to tokens array
      NSLog(@"tokens[%d] = %@", tokenCount, tokenWord);
      tokenCount++;
      tokenWord = @""; // reset tokenWord
      continue;
    }

    // look for end-of-line i.e., a carriageReturn followed by linefeed
    if (([csvString characterAtIndex:charIndex] == carriageReturnSentinel) && ([csvString characterAtIndex:charIndex+1] == linefeedSentinel)) {
      tokens[tokenCount] = tokenWord; // grab the current tokenWord and add to tokens array. Note, this is the last token on the current line
      NSLog(@"tokens[%d] = %@", tokenCount, tokenWord);
      tokenCount++;
      tokenWord = @""; // reset tokenWord
      charIndex++; // skip over carriage return
      continue; //  skip linefeed
    }

    // Build tokenWord tokenChar-by-tokenChar
    tokenWord = [tokenWord stringByAppendingString:tokenChar];
  } // for loop

  tokens[tokenCount] = tokenWord; // grab the current tokenWord and add to tokens array. Note this is the last token in the file. 
  NSLog(@"tokens[%d] = %@", tokenCount, tokenWord);

  NSLog(@"tokenCount = %d", tokenCount);



//  NSLog(@"FilesVC - Token count = %lu", (unsigned long)[tokens count]);
//  for(int i=0; i<[tokens count]; i++) {
//    NSLog(@"FilesVC - token[%d] length = %lu token = %@ ",i, (unsigned long)[[tokens objectAtIndex:i]length], [tokens objectAtIndex:i]);
//    for(int j=0; j<[[tokens objectAtIndex:i]length]; j++) {
//      char token = [[tokens objectAtIndex:i]characterAtIndex:j];
//
//
//      NSLog(@"token[%d][%d] = %c Unicode = %d", i, j, token, token);
//    }
//
//  }

}



@end
