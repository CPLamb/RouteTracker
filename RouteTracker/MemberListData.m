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


#pragma mark - Custom methods

- (void)loadPlistData {
//    NSLog(@"Loads the Plist into member array either from the main bundle (read only) or from the documents directory files downloaded from Google sheets");
    
    [self loadFileFromDocuments];
    
// Copy members array into the names array which can later be sorted for other views
    self.namesArray = [NSArray arrayWithArray:self.membersArray];
}

- (void)loadFileFromDocuments {
    NSLog(@"READS the Plist formatted file & converts it into an array (of dictionaries)");
    
    NSString *filename = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];
//    NSString *filename = @"EdibleMontereyDistributionListCurrent";  // emergency fix DELETE
    NSError *errorDescr = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:filename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSLog(@"We couldn't find the file so we'll load from the bundle");
        plistPath = [[NSBundle mainBundle] pathForResource:@"SCWaveDistributionListCurrent" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSArray *temp = [NSPropertyListSerialization propertyListWithData:plistXML
                                                                         options:NSPropertyListImmutable
                                                                          format:NULL
                                                                           error:&errorDescr];
    
    if (!temp) {
        NSLog(@"Error reading plist: %@, format %lu", errorDescr, (unsigned long)format);
    }
    self.membersArray = [NSMutableArray arrayWithArray:temp];
//    NSLog(@"Took no time at all! %@", [temp objectAtIndex:[temp count]-1]);
    
}

-(void)modifyMemberListFile :(NSDictionary*)completeEntry withUpdates:(NSDictionary*)updatedEntry
{
    
    NSString *filename = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];
    
    NSError *errorDescr = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:filename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSLog(@"We couldn't find the file so we'll load from the bundle");
        plistPath = [[NSBundle mainBundle] pathForResource:@"SCWaveDistributionListCurrent" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSArray *temp = [NSPropertyListSerialization propertyListWithData:plistXML
                                                              options:NSPropertyListImmutable
                                                               format:NULL
                                                                error:&errorDescr];

    if (!temp) {
        NSLog(@"Error reading plist: %@, format %lu", errorDescr, (unsigned long)format);
    }
    NSMutableArray *plistEdibleContent = [[NSMutableArray alloc] initWithArray:temp];
    for (int i = 0; i < [plistEdibleContent count]; i++){
        NSDictionary *currentEntry = [plistEdibleContent objectAtIndex:i];
        if([[currentEntry objectForKey:@"Index"] isEqualToString:[completeEntry objectForKey:@"Index"]]) {
            [plistEdibleContent replaceObjectAtIndex:i withObject:completeEntry];
            break;
        }
    }
    [plistEdibleContent writeToFile:plistPath atomically:YES];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.arrayToBeUploaded addObject:updatedEntry];
    
    /*
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString    *strTime = [df stringFromDate:[NSDate date]];
    NSString *modifiedFilename = [NSString stringWithFormat:@"%@-%@",filename, strTime];
    
    [[NSUserDefaults standardUserDefaults] setObject:modifiedFilename forKey:@"updated_plist"];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingPathComponent:modifiedFilename];
    [delegate.arrayToBeUploaded writeToFile:filePath atomically:YES];
    */
    [self createCSVFile:updatedEntry];
}

-(void)createCSVFile:(NSDictionary*)updatedEntry
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    NSString *filename = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString    *strTime = [df stringFromDate:[NSDate date]];
    NSString *modifiedFilename = [NSString stringWithFormat:@"%@-%@.csv",filename, strTime];
    
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:modifiedFilename];
    
    [[NSUserDefaults standardUserDefaults] setObject:modifiedFilename forKey:@"updated_plist"];
    
    NSArray *keysArray = [updatedEntry allKeys];
    
    NSString *firstLine = [keysArray componentsJoinedByString:@","];
    
    NSMutableString *csvString = [[NSMutableString alloc] initWithString:firstLine];
    csvString = [[csvString stringByAppendingString:@"\n"] mutableCopy];
    
    //save field names in the first line of the CSV file
    [csvString writeToFile:filePath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    for (int i = 0; i < [delegate.arrayToBeUploaded count]; i++){
        NSDictionary *entry = [delegate.arrayToBeUploaded objectAtIndex:i];
        for (id key in entry) {
            id value = [entry objectForKey:key];
            if ([key isEqualToString:@"Name"]) {
                NSString * newName = [value stringByReplacingOccurrencesOfString:@"," withString:@""];
                csvString = [[csvString stringByAppendingString:newName] mutableCopy];
            } else if ([key isEqualToString:@"Address"]) {
                NSString * newAddress = [value stringByReplacingOccurrencesOfString:@"," withString:@""];
                csvString = [[csvString stringByAppendingString:newAddress] mutableCopy];
            } else if ([key isEqualToString:@"Comments"]) {
                NSString * newComments = [value stringByReplacingOccurrencesOfString:@"," withString:@""];
                csvString = [[csvString stringByAppendingString:newComments] mutableCopy];
            } else if ([key isEqualToString:@"Notes"]) {
                NSString * newNotes = [value stringByReplacingOccurrencesOfString:@"," withString:@""];
                csvString = [[csvString stringByAppendingString:newNotes] mutableCopy];
            } else {
                csvString = [[csvString stringByAppendingString:[NSString stringWithFormat:@"%@",value]] mutableCopy];
            }
            csvString = [[csvString stringByAppendingString:@","] mutableCopy];
        }
        [csvString deleteCharactersInRange:NSMakeRange([csvString length]-1, 1)];
         csvString = [[csvString stringByAppendingString:@"\n"] mutableCopy];
        [csvString writeToFile:filePath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
    }
}

 @end
