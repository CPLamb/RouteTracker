//
//  DetailViewController.m
//  RouteTracker
//
//  Created by Chris Lamb on 12/29/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

- (void)hideTap:(UIGestureRecognizer *)gestureRecognizer;

@end

@implementation DetailViewController


#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"Selected indexPath = %@", self.selectedIndexPath);
// Assigns values to the text fields
    self.nameTextField.text = [self.detailItem objectForKey:@"Name"];
    self.deliverTextField.text = [self.detailItem objectForKey:@"Total Quantity to Deliver"];
    self.returnedTextField.text = [self.detailItem objectForKey:@"Quantity Returned"];
    self.notesTextField.text = [self.detailItem objectForKey:@"Notes"];
    self.driverTextField.text = [self.detailItem objectForKey:@"Driver"];
    self.categoryTextField.text = [self.detailItem objectForKey:@"Category"];
    self.advertiserTextField.text = [self.detailItem objectForKey:@"Advert iser"];

    self.latitudeTextField.text = [self.detailItem objectForKey:@"Latitude"];
    self.longitudeTextField.text = [self.detailItem objectForKey:@"Longitude"];
    
    self.addressTextField.text = [self.detailItem objectForKey:@"Street"];
    self.cityTextField.text = [self.detailItem objectForKey:@"City"];
    self.stateTextField.text = [self.detailItem objectForKey:@"State"];
    self.zipTextField.text = [self.detailItem objectForKey:@"Zipcode"];
    
    self.contactTextField.text = [self.detailItem objectForKey:@"Contact Name"];
    self.phoneTextField.text = [self.detailItem objectForKey:@"Contact Phone"];

// Tap to hide keyboard
    UITapGestureRecognizer *hideKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTap:)];
    [self.view addGestureRecognizer:hideKeyboardTap];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"Save the modified details to the detailItem mutableDictionart");
    
    [self.detailItem setValue:self.nameTextField.text forKey:@"Name"];
//    [self.detailItem setObject:@"Name" forKey:self.nameTextField.text];
    NSLog(@"detailItem Name = %@", [self.detailItem objectForKey:@"Name"]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)hideTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
    NSLog(@"Hides the keyboard");
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Moves to other view & sets the detailItem to the selected item
    
    NSLog(@"Segue ID is %@", [segue identifier]);
    
    if ([[segue identifier] isEqualToString:@"showMap"]) {
        [[segue destinationViewController] setDetailItem:self.detailItem];
    }
}


@end
