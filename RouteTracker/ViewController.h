//
//  ViewController.h
//  QuickstartApp
//
//  Created by Chris Lamb on 3/17/16.
//  Copyright © 2016 com.SantaCruzNewspaperTaxi. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLService.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) GTLService *service;
@property (nonatomic, strong) UITextView *output;

@end
