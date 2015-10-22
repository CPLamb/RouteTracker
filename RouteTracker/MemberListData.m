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

- (id)init {                        // overridden initializer
    if ((self = [super init])) {
        [self loadPlistData];
    }
    return self;
    
}

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
//    NSURL *fileURL = [mainBundle URLForResource:@"SCWaveDistributionListCurrent" withExtension:@"plist"];  //MontereyWaveDistributionList

    NSLog(@"The Plist filename & directory is %@", fileURL);
    
    // Old link for pList = https://dl.dropboxusercontent.com/u/13142051/TLFMemberList.plist
    // Public dropBox URL for the pList = https://www.dropbox.com/s/j1op2cn56abrdlw/TLFMemberList.plist
    
// Loads the file from the web
//    NSString *fileURLString = @"https://dl.dropboxusercontent.com/u/13142051/TLFMemberList.plist";
//    NSURL *fileURL = [[NSURL alloc]initWithString:fileURLString];

    self.membersArray = [NSArray arrayWithContentsOfURL:fileURL];
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
@end
