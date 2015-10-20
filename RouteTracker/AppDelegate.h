//
//  AppDelegate.h
//  RouteTracker
//
//  Created by Chris Lamb on 12/27/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemberListData.h"

@class MemberListData;  

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MemberListData *_memberData;
}
@property (strong, nonatomic) MemberListData *memberData;
@property (strong, nonatomic) UIWindow *window;

@end

