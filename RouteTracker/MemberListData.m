//
//  MemberListData.m
//  ThinkLocal
//
//  Created by Chris Lamb on 5/18/13.
//  Copyright (c) 2013 Chris Lamb. All rights reserved.
//

#import "MemberListData.h"

@implementation MemberListData
@synthesize namesArray = _namesArray;
@synthesize membersArray = _membersArray;

//- (id)init {                        // overridden initializer
//    if ((self = [super init])) {
//        [self loadPlistData];
//    }
//    return self;
//    
//}

#pragma mark - Custom methods

- (void)loadPlistData {
    // Loads the Plist into member array either from web or locally
    
// Loads file locally from either sheet
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *fileURL = [[NSURL alloc] init];
    
// Use NSUserDefault to determine which file to load
    NSInteger dataFilenameIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_spreadsheet"];
    switch(dataFilenameIndex) {
        
// Alloc/init the fileURL outside the boundaries of switch/case statement
        case 0:
            fileURL = [mainBundle URLForResource:@"SCWaveDistributionListCurrent" withExtension:@"plist"];  //MontereyWaveDistributionList
            break;
        case 1:
            fileURL = [mainBundle URLForResource:@"MontereyWaveDistributionList" withExtension:@"plist"];  //MontereyWaveDistributionList
            break;
    }
//    NSLog(@"The Plist filename & directory is %@", fileURL);
    
    // MontereyWaves dropbox link = https://dl.dropboxusercontent.com/u/13142051/MontereyWaveDistributionList.plist
    // SCWaves dropbox link - https://dl.dropboxusercontent.com/u/13142051/SCWaveDistributionListCurrent.plist
    
// Loads the file from the web
//    NSString *fileURLString = @"https://dl.dropboxusercontent.com/u/13142051/TLFMemberList.plist";
//    NSURL *fileURL = [[NSURL alloc]initWithString:fileURLString];

  NSLog(@"MemberListData -loadPlistData -- fileURL = \n%@", fileURL);
    self.membersArray = [NSArray arrayWithContentsOfURL:fileURL];
//  NSLog(@"MemberListData -loadPlistData -- self.membersArray = \n%@", self.membersArray);

//    NSLog(@"MEMBERLISTDATA Array count %d", [self.membersArray count]);

    // Copy members array into the names array which can later be sorted for other views
    self.namesArray = [NSArray arrayWithArray:self.membersArray];

    
    
    // loads the web Plist on another thread
//    [self loadPlistURL];   temporaary disable 9/16
}

- (void)loadPlistURL {
    // Loads the Plist from the web on another thread, and if both array counts are
    // equal it copies the web version over the local version. And reloads the data
    
    // Public dropbox link to data - https://dl.dropboxusercontent.com/u/13142051/TLFMemberList.plist
    NSString *fileURLString = @"https://www.dropbox.com/s/j1op2cn56abrdlw/TLFMemberList.plist";
    NSURL *fileURL = [[NSURL alloc]initWithString:fileURLString];
    
    // Assign the URL command to another string
    dispatch_queue_t downloadQueue = dispatch_queue_create("Plist downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        NSArray *membersURLArray = [NSArray arrayWithContentsOfURL:fileURL];
        
        // dispatches to the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // compares counts of each array & allows copy if the are equal
            if ([self.membersArray count] == [membersURLArray count]) {
//                NSLog(@"let's overwrite NOW!!!");
                
                self.membersArray = [NSArray arrayWithArray:membersURLArray];
 //               NSLog(@"Array count %d", [self.membersArray count]);
                
//                [self.tableView reloadData];
            } else {
//                NSLog(@"Download FAILED!!!!");
//                NSLog(@"Array count %d", [membersURLArray count]);
            }
        });
    });
}
/*
+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
*/

 // Note: fileContent is the variable displaying loaded data on the file loaded screen (this note probably needs to be deleted)

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
  
  NSLog(@"FilesVC csvDataToArrayOfDictionaries -- membersArray = \n%@", membersArray);
  
  return membersArray;
}
@end
