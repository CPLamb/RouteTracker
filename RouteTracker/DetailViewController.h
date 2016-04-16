//
//  DetailViewController.h
//  RouteTracker
//
//  Created by Chris Lamb on 12/29/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableDictionary *detailItem;  // Selected location
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;     //store index path for editing

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *deliverTextField;
@property (weak, nonatomic) IBOutlet UITextField *returnedTextField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextField;
@property (weak, nonatomic) IBOutlet UITextField *driverTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *advertiserTextField;
@property (weak, nonatomic) IBOutlet UITextField *latitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipTextField;
@property (weak, nonatomic) IBOutlet UITextView *contactTextField;
@property (weak, nonatomic) IBOutlet UITextView *phoneTextField;
@property BOOL textFieldChanged;

- (IBAction)geocodeButton:(UIButton *)sender;

@end
