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
//        [self loadData];
//    }
//    return self;
//
//}

#pragma mark - Custom methods
/*!
 * @discussion This method loads data either from the main bundle, or the saved documents and stores in self.membersArray
 * @param
 */
- (void)loadData {
    NSLog(@"Loads the data into member array either from the main bundle (read only) or from the documents directory files downloaded from Google sheets");

    NSInteger currentMediaSource = [[NSUserDefaults standardUserDefaults]      integerForKey:@"selected_media_source"];
//    load from selected media source
    switch (currentMediaSource) {
        case 0:
            [self loadPlistFromMainBundle];
            break;
        case 1:
            [self loadFileFromDocumentsDirectory];
            break;
    }

    // Copy members array into the names array which can later be sorted for other views
    self.namesArray = [NSMutableArray arrayWithArray:self.membersArray];
}

- (void) loadPlistFromMainBundle {
    NSLog(@"MemberListData -loadPlistFromMainBundle -- Loads a file from the main bundle");
    // Loads file locally from either sheet
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *fileURL = [[NSURL alloc] init];

    // Use NSUserDefault to determine which file to load
    NSString *dataFilename = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_spreadsheet"];

    fileURL = [mainBundle URLForResource:dataFilename withExtension:@"plist"];

    NSLog(@"MemberListData -loadPlistData -- fileURL = %@", fileURL);

    // read pList
    self.membersArray = [NSMutableArray arrayWithContentsOfURL:fileURL];

    //    NSLog(@"MemberListData -loadPlistData -- self.membersArray = \n%@", self.membersArray);
    NSLog(@"MemberListData -loadPlistData -- Array count %lu", (unsigned long)[self.membersArray count]);
}

- (void)loadFileFromDocumentsDirectory {
    NSLog(@"MemberListData -loadFileFromDocumentsDirectory -- Loads a file from the DOCUMENTS directory");

    // select the filename from NSUserDefaults
    NSString *selectedFile = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];

    // Add the directory path to the string
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:selectedFile];

    // Get the csv data file from the documents directory
    NSData *csvData;
    csvData = [[NSFileManager defaultManager] contentsAtPath:path];
    NSString *csvDataString = [[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding];

    // Parse the csv string file into an Array of Dictionaries
    self.membersArray = [self csvDataToArrayOfDictionaries:csvDataString];

    NSLog(@"MemberListData -- The membersArray = %@", self.membersArray);
}

/*
 + (NSString *) applicationDocumentsDirectory
 {
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
 return basePath;
 }
 */


// http://www.raywenderlich.com/66395/documenting-in-xcode-with-headerdoc-tutorial

/*!
 * @discussion This method accepts a Google spreadsheet formated as a csv text string and returns an Array of Dictionaries
 * @param
 */
- (NSMutableArray*)csvDataToArrayOfDictionaries: (NSString *) csvFile {
    NSLog(@"MembersListData -csvDataToArrayOfDictionaries: -- The string we're looking at is \n>>>>%@<<<<", csvFile);

    // Build tokens array from csvFile

    NSUInteger stringLength = [csvFile length];
    NSLog(@"MembersListData -- String length = %lu", stringLength);

    // initialization
    NSString *tokenWord = @"";
    NSMutableArray *tokens = [[NSMutableArray alloc]init];
    int tokenCount = 0;
    bool insideQuote = false;
    bool ignoreComma = false;
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

            //      NSLog(@"MemberListdata tokens[%d] = %@", tokenCount, tokenWord);
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

    NSLog(@"MemberListdata tokenCount = %d", tokenCount);

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
    
    NSLog(@"MemberListdata -csvDataToArrayOfDictionaries -- membersArray = \n%@", membersArray);
    
    return membersArray;
}
@end
