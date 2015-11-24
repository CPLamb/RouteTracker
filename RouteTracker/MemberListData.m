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
//    NSLog(@"Loads the Plist into member array either from the main bundle (read only) or from the documents directory files downloaded from Google sheets");
    
    [self loadFileFromDocuments];
    
//// Loads file locally from either sheet
//    NSBundle *mainBundle = [NSBundle mainBundle];
//    NSURL *fileURL = [[NSURL alloc] init];
//    
//// Use NSUserDefault to determine which file to load
//    NSString *dataFilename = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_spreadsheet"];
//
//// Alloc/init the fileURL outside the boundaries of switch/case statement
//        fileURL = [mainBundle URLForResource:dataFilename withExtension:@"plist"];
//
//    NSLog(@"MemberListData -loadPlistData -- fileURL = %@", fileURL);
//    
//// The secret JUICE - loads the membersArray from the file
//    self.membersArray = [NSArray arrayWithContentsOfURL:fileURL];
//
////    NSLog(@"MemberListData -loadPlistData -- self.membersArray = \n%@", self.membersArray);
//    NSLog(@"MEMBERLISTDATA Array count %d", [self.membersArray count]);
//
    
    
// Copy members array into the names array which can later be sorted for other views
    self.namesArray = [NSArray arrayWithArray:self.membersArray];
    
    // loads the web Plist on another thread
//    [self loadPlistURL];   temporaary disable 9/16
}

- (void)loadFileFromDocuments {
    NSLog(@"READS the Plist formatted file & converts it into an array (of dictionaries)");
    
    NSString *filename = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];
    
    NSError *errorDescr = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:filename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSLog(@"We couldn't find the file so we'll load from the bundle");
        plistPath = [[NSBundle mainBundle] pathForResource:@"EdibleMontereyDistributionList" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSArray *temp = (NSArray *)[NSPropertyListSerialization propertyListWithData:plistXML
                                                                         options:kCFPropertyListXMLFormat_v1_0
                                                                          format:kCFPropertyListImmutable
                                                                           error:&errorDescr];
    
    if (!temp) {
        NSLog(@"Error reading plist: %@, format %lu", errorDescr, (unsigned long)format);
    }
    self.membersArray = [NSArray arrayWithArray:temp];
    NSLog(@"Took no time at all! %@", [temp objectAtIndex:[temp count]-1]);

    
    
//    NSLog(@"MemberListData - Loads a file from the DOCUMENTS directory");
//    
//// select the filename from NSUserDefaults
//    NSString *selectedFile = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];
// //   NSString *selectedFile = @"MontereyWaveDistributionList";
//
//// Add the directory path to the string
//    NSString *path;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    path = [paths objectAtIndex:0];
//    path = [path stringByAppendingPathComponent:selectedFile];
//
//// Get the data from the documents directory
//    NSData *fileData;
//    fileData = [[NSFileManager defaultManager] contentsAtPath:path];
//    NSString *fileDataString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
//    
//// Parse the csv string file to a plist
////    self.membersArray = [self csvDataToArrayOfDictionaries:fileDataString];
//    
//// Perform the conversion fileURL to array
////    NSURL *fileURL = [[NSURL alloc]initWithString:path];
//    self.membersArray = [NSMutableArray arrayWithContentsOfFile:fileDataString];
//    NSLog(@"The membersArray = %@", self.membersArray);
}

// Remove this - no longer used
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

//    NSLog(@"Character[%d] =  %@", charIndex, tokenChar);


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
//        NSLog(@" plist internal loop index %d", i);
    }

    plistData = [plistData stringByAppendingString:@"\t</dict>\n"];
 //     NSLog(@" plist EXTERNAL loop index %d", tokenIndex);

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
