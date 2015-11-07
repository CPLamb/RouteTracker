//
//  FilesViewController.h
//  RouteTracker
//
//  Created by Chris Lamb on 1/4/15.
//  Copyright (c) 2015 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLDrive.h"
#import "DrEditFileEditDelegate.h"

@interface FilesViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>

@property GTLServiceDrive *driveService;
@property GTLDriveFile *selectedFile;
@property id<DrEditFileEditDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UITextField *modifiedDateTextfield;

@property (weak, nonatomic) IBOutlet UITextField *numberOfRowsTextfield;
@property (weak, nonatomic) IBOutlet UITextView *fileContent;

@property (strong, nonatomic) NSArray *namesArray;  // array of indexed array of dictionaries
@property (strong, nonatomic) NSArray *membersArray;    // complete list derived from the PList

@end
