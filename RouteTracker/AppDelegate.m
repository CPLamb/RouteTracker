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
    NSLog(@"AppDelegate -- application didFinishLaunchingWithOptions");

    // initialize defaults for app parameters using NSUserDefault
    NSString *dateKey    = @"dateKey";
    NSDate *lastRead    = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:dateKey];

    NSLog(@"AppDelegate -- lastRead = %@", lastRead);

    // App first run: set up user defaults.
    if (lastRead == nil)
    {
        NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
        
        // NSUserDefault setup for passing info around the app the starting default values.
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"list_filtered"];
        [[NSUserDefaults standardUserDefaults] setObject:@"EdibleMontereyDistributionList" forKey:@"selected_spreadsheet"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"selected_map_type"];
        [[NSUserDefaults standardUserDefaults] setObject:@"ALL" forKey:@"selected_driver"];
        [[NSUserDefaults standardUserDefaults] setObject:@"initialString" forKey:@"selected_plist"];
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

    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
