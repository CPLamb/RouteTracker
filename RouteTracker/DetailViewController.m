//
//  DetailViewController.m
//  RouteTracker
//
//  Created by Chris Lamb on 12/29/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import "DetailViewController.h"
#import "MemberListData.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>

@interface DetailViewController ()<CLLocationManagerDelegate>

- (void)hideTap:(UIGestureRecognizer *)gestureRecognizer;

@end

@implementation DetailViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeDetailItem];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self initializeDetailItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"Save the modified details to the detailItem mutableDictionary");
    
    [self updateDetailItem];
    

}

-(void)initializeDetailItem
{
    self.textFieldChanged = FALSE;
    
    // IndexPath of the selected detailItem dictionary
    NSLog(@"Selected indexPath = %@", self.selectedIndexPath);
    int section = (int)self.selectedIndexPath.section;
    int row = (int)self.selectedIndexPath.row;
    
    NSArray *indexPathArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:row] , [NSNumber numberWithInt:section], nil];
    [[NSUserDefaults standardUserDefaults] setObject:indexPathArray forKey:@"selected_indexPath"];
    
    
    // Assigns values to the text fields
    self.nameTextField.text = [self.detailItem objectForKey:@"Name"];
    self.deliverTextField.text = [self.detailItem objectForKey:@"Total Quantity to Deliver"];
    self.returnedTextField.text = [self.detailItem objectForKey:@"Delivered to Date"];
    self.notesTextField.text = [self.detailItem objectForKey:@"Notes"];
    self.driverTextField.text = [self.detailItem objectForKey:@"Driver"];
    self.categoryTextField.text = [self.detailItem objectForKey:@"Category"];
    self.advertiserTextField.text = [self.detailItem objectForKey:@"Advertiser"];
    
    self.latitudeTextField.text = [self.detailItem objectForKey:@"Latitude"];
    self.longitudeTextField.text = [self.detailItem objectForKey:@"Longitude"];
    
    self.addressTextField.text = [self.detailItem objectForKey:@"Street"];
    self.cityTextField.text = [self.detailItem objectForKey:@"City"];
    self.stateTextField.text = [self.detailItem objectForKey:@"State"];
    self.zipTextField.text = [self.detailItem objectForKey:@"Zipcode"];
    
    self.commentsTextField.text = [self.detailItem objectForKey:@"Comment"];
   // self.commentsTextField.text = [self.detailItem objectForKey:@"Contact Name"];
    self.phoneTextField.text = [self.detailItem objectForKey:@"Contact Number"];
    
    // Tap to hide keyboard
    UITapGestureRecognizer *hideKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTap:)];
    [self.view addGestureRecognizer:hideKeyboardTap];
}
-(void)updateDetailItem
{
        // A mutable Dictionary must be created from the original for editing?
        NSMutableDictionary *mutableDetailItem = [NSMutableDictionary dictionaryWithDictionary:self.detailItem];
        [mutableDetailItem setValue:self.nameTextField.text forKey:@"Name"];
        [mutableDetailItem setValue:self.deliverTextField.text forKey:@"Total Quantity to Deliver"];
        [mutableDetailItem setValue:self.returnedTextField.text forKey:@"Delivered to Date"];
        [mutableDetailItem setValue:self.notesTextField.text forKey:@"Notes"];
        [mutableDetailItem setValue:self.driverTextField.text forKey:@"Driver"];
        [mutableDetailItem setValue:self.categoryTextField.text forKey:@"Category"];
        [mutableDetailItem setValue:self.advertiserTextField.text forKey:@"Advertiser"];
        
        [mutableDetailItem setValue:self.latitudeTextField.text forKey:@"Latitude"];
        [mutableDetailItem setValue:self.longitudeTextField.text forKey:@"Longitude"];
        
        [mutableDetailItem setValue:self.addressTextField.text forKey:@"Street"];
        [mutableDetailItem setValue:self.cityTextField.text forKey:@"City"];
        [mutableDetailItem setValue:self.stateTextField.text forKey:@"State"];
        [mutableDetailItem setValue:self.zipTextField.text forKey:@"Zipcode"];
        
        [mutableDetailItem setValue:self.commentsTextField.text forKey:@"Comment"];
        //   [mutableDetailItem setValue:self.contactTextField.text forKey:@"Contact Name"];
        [mutableDetailItem setValue:self.phoneTextField.text forKey:@"Contact Number"];
        
        NSLog(@"detailItem Name = %@", mutableDetailItem);
        
        // Stores the detailItem to NSUserDefaults
      //  NSDictionary *modifiedDictionary = [NSDictionary dictionaryWithDictionary:mutableDetailItem];
        NSMutableDictionary *modifiedDictionary = [[NSMutableDictionary alloc] init];
        [modifiedDictionary setValue:[self.detailItem objectForKey:@"Index"] forKey:@"Index"];
        
        if (![[self.detailItem objectForKey:@"Name"] isEqualToString:self.nameTextField.text]) {
            [modifiedDictionary setValue:self.nameTextField.text forKey:@"Name"];
        }
        if (![[self.detailItem objectForKey:@"Total Quantity to Deliver"] isEqualToString:self.deliverTextField.text]) {
            [modifiedDictionary setValue:self.deliverTextField.text forKey:@"Total Quantity to Deliver"];
        }
        if (![[self.detailItem objectForKey:@"Delivered to Date"] isEqualToString:self.returnedTextField.text]) {
            [modifiedDictionary setValue:self.returnedTextField.text forKey:@"Delivered to Date"];
        }
        if (![[self.detailItem objectForKey:@"Notes"] isEqualToString:self.notesTextField.text]) {
            [modifiedDictionary setValue:self.notesTextField.text forKey:@"Notes"];
        }
        if (![[self.detailItem objectForKey:@"Driver"] isEqualToString:self.driverTextField.text]) {
            [modifiedDictionary setValue:self.driverTextField.text forKey:@"Driver"];
        }
        if (![[self.detailItem objectForKey:@"Category"] isEqualToString:self.categoryTextField.text]) {
            [modifiedDictionary setValue:self.categoryTextField.text forKey:@"Category"];
        }
        if (![[self.detailItem objectForKey:@"Advertiser"] isEqualToString:self.advertiserTextField.text]) {
            [modifiedDictionary setValue:self.advertiserTextField.text forKey:@"Advertiser"];
        }
        if (![[self.detailItem objectForKey:@"Latitude"] isEqualToString:self.latitudeTextField.text]) {
            [modifiedDictionary setValue:self.latitudeTextField.text forKey:@"Latitude"];
        }
        if (![[self.detailItem objectForKey:@"Longitude"] isEqualToString:self.longitudeTextField.text]) {
            [modifiedDictionary setValue:self.longitudeTextField.text forKey:@"Longitude"];
        }
        if (![[self.detailItem objectForKey:@"Street"] isEqualToString:self.addressTextField.text]) {
            [modifiedDictionary setValue:self.addressTextField.text forKey:@"Street"];
        }
        if (![[self.detailItem objectForKey:@"City"] isEqualToString:self.cityTextField.text]) {
            [modifiedDictionary setValue:self.cityTextField.text forKey:@"City"];
        }
        if (![[self.detailItem objectForKey:@"State"] isEqualToString:self.stateTextField.text]) {
            [modifiedDictionary setValue:self.stateTextField.text forKey:@"State"];
        }
        if (![[self.detailItem objectForKey:@"Zipcode"] isEqualToString:self.zipTextField.text]) {
            [modifiedDictionary setValue:self.zipTextField.text forKey:@"Zipcode"];
        }
        if (![[self.detailItem objectForKey:@"Comment"] isEqualToString:self.commentsTextField.text]) {
       // if (![[self.detailItem objectForKey:@"Contact Name"] isEqualToString:self.commentsTextField.text]) {
            [modifiedDictionary setValue:self.commentsTextField.text forKey:@"Comment"];
        }
        if (![[self.detailItem objectForKey:@"Contact Number"] isEqualToString:self.phoneTextField.text]) {
            [modifiedDictionary setValue:self.phoneTextField.text forKey:@"Contact Number"];
        }
        
        
        [[NSUserDefaults standardUserDefaults] setObject:mutableDetailItem forKey:@"selected_member"];
        if ([[modifiedDictionary allKeys] count] > 1) {
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;
            [delegate.memberData modifyMemberListFile:mutableDetailItem withUpdates:modifiedDictionary];
        }

}

- (IBAction)textFieldDidChange:(id)sender {
    self.textFieldChanged = TRUE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)hideTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
//    NSLog(@"Hides the keyboard");
}

- (IBAction)geocodeButton:(UIButton *)sender {
    NSLog(@"Changes location's lat/long values");
    
   // NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] initWithDictionary:self.detailItem];
    
    CLLocationManager *lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    lm.desiredAccuracy = kCLLocationAccuracyBest;
    lm.distanceFilter = kCLDistanceFilterNone;
    [lm startUpdatingLocation];

    NSString *userLatitude = [NSString stringWithFormat:@"%f",
                              lm.location.coordinate.latitude];
    NSString *userLongitude = [NSString stringWithFormat:@"%f",lm.location.coordinate.longitude];
    
    self.latitudeTextField.text = userLatitude;
    self.longitudeTextField.text = userLongitude;

    /*
    [myDictionary setValue:[self.detailItem objectForKey:@"Index"] forKey:@"Index"];
    [myDictionary setValue:userLatitude forKey:@"Latitude"];
    [myDictionary setValue:userLongitude forKey:@"Longitude"];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.memberData modifyMemberListFile:self.detailItem withUpdates:myDictionary];*/
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Moves to other view & sets the detailItem to the selected item
    
//    NSLog(@"Segue ID is %@", [segue identifier]);
    
    if ([[segue identifier] isEqualToString:@"showMap"]) {
        [[segue destinationViewController] setDetailItem:self.detailItem];
    }
}

@end
