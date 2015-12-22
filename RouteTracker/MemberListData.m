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
 //   NSString *filename = @"EdibleMontereyDistributionListCurrent";  // emergency fix DELETE
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

 @end
