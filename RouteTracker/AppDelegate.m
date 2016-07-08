//
//  AppDelegate.m
//  RouteTracker
//
//  Created by Chris Lamb on 12/27/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
//@synthesize memberData = _memberData;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

// initialize defaults for app parameters using NSUserDefault
    NSString *dateKey    = @"dateKey";
    NSDate *lastRead    = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:dateKey];

    // App first run: set up user defaults.
    if (lastRead == nil)
    {
        NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
        
// NSUserDefault setup for passing info around the app the starting default values.
        [[NSUserDefaults standardUserDefaults] setInteger:50 forKey:@"copies_bundle"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"list_filtered"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"initial_filter"];
       [[NSUserDefaults standardUserDefaults] setObject:@"EdibleMontereyDistributionListCurrent" forKey:@"selected_spreadsheet"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"selected_map_type"];
        [[NSUserDefaults standardUserDefaults] setObject:@"ALL" forKey:@"selected_driver"];
        [[NSUserDefaults standardUserDefaults] setObject:@"EdibleMontereyDistributionList" forKey:@"selected_plist"];
        [[NSUserDefaults standardUserDefaults] setObject:@"SCWavesSantaLogo" forKey:@"selected_photo"];
        [[NSUserDefaults standardUserDefaults] setObject:@"modifiedData" forKey:@"updated_plist"];
        [[NSUserDefaults standardUserDefaults] setObject:@"initialDictionary" forKey:@"selected_member"];
        [[NSUserDefaults standardUserDefaults] setObject:@"selectedIndexPath" forKey:@"selected_indexPath"];
        
        NSLog(@"AppDelegate -- initialSpreadsheet = %@",[[NSUserDefaults standardUserDefaults]stringForKey:@"selected_spreadsheet"] );
        // sync the defaults to disk
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // loadPlistData
    self.memberData = [[MemberListData alloc] init];
    [self.memberData loadPlistData];
    
    self.arrayToBeUploaded = [[NSMutableArray alloc] init];

    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];
    
    return YES;
}

@end
