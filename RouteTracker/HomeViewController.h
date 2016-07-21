//
//  HomeViewController.h
//  RouteTracker
//
//  Created by Chris Lamb on 1/6/15.
//  Copyright (c) 2015 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * _Nonnull __strong kRouterPickerValueChangeNotification = @"router.tracker.router.picker.change";
static NSString * _Nonnull __strong kListSearchFilterChangeNotification = @"router.tracker.router.filter.change";
static NSString * _Nonnull __strong kListTableStartNewSearchNotification = @"router.tracker.new.serach";
static NSString * _Nonnull __strong kListCopiesBundleChangeNotification = @"router.tracker.copies.bundle";

static NSString * _Nonnull __strong kDidUpdateDetailItem = @"router.tracker.did.update.detail";

@interface HomeViewController : UIViewController

@end
