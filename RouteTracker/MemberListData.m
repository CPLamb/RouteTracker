//
//  MemberListData.m
//  ThinkLocal
//
//  Created by Chris Lamb on 5/18/13.
//  Copyright (c) 2013 Chris Lamb. All rights reserved.
//

#import "MemberListData.h"
#import "CHCSVParser.h"

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
    
    BOOL entryFound = FALSE;
    for (int i = 0; i < [delegate.arrayToBeUploaded count]; i++){
        NSDictionary *entry = [delegate.arrayToBeUploaded objectAtIndex:i];
        if ([[entry objectForKey:@"Index"] isEqualToString:[updatedEntry objectForKey:@"Index"]]) {
            [delegate.arrayToBeUploaded replaceObjectAtIndex:i withObject:updatedEntry];
            entryFound = TRUE;
            break;
        }
    }
    if (!entryFound) {
        [delegate.arrayToBeUploaded addObject:updatedEntry];
    }
    
    [self createCSVFile];
}

-(void)createCSVFile
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
    
    // Create in memory writer
    NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
    CHCSVWriter *writer = [[CHCSVWriter alloc] initWithOutputStream:stream
                                                           encoding:NSUTF8StringEncoding
                                                          delimiter:','];
    
    // Construct csv
    
    // Write header...
    NSArray *keys = [delegate.arrayToBeUploaded[0] allKeys];
    [writer writeLineOfFields:keys];
    
    // ...then fill the rows
    for (NSDictionary *item in delegate.arrayToBeUploaded) {
        for (NSString *key in keys) {
            NSString *value = [item objectForKey:key];
            [writer writeField:value];
        }
        
        [writer finishLine];
    }
    [writer closeStream];
    
    NSData *contents = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    NSString *csvString = [[NSString alloc] initWithData:contents
                                                encoding:NSUTF8StringEncoding];
    [csvString writeToFile:filePath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];

}
 @end
