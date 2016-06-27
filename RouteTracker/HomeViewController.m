//
//  HomeViewController.m
//  RouteTracker
//
//  Created by Chris Lamb on 1/6/15.
//  Copyright (c) 2015 com.SantaCruzNewspaperTaxi. All rights reserved.
//

/*
 This link talks about breaking up storyboards
 http://www.newventuresoftware.com/blog/organizing-xcode-projects-using-multiple-storyboards/
 */

#import "HomeViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *AppMainLogo;
@property (weak, nonatomic) IBOutlet UILabel *selectedMagazineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedMagazineLogo;
@property (nonnull, strong) CLLocationManager *locationManager;
@end

@implementation HomeViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        self.locationManager = [CLLocationManager new];
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *dataFilenameIndex = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];
    
    NSLog(@"HomeVC -- dataFilenameIndex = %@", dataFilenameIndex.description);
    
    // Sets up display of magazine loaded
    self.selectedMagazineLabel.text = dataFilenameIndex.description;
    
    NSString *selectedMagazinePhotoName = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_photo"];
    
    self.selectedMagazineLogo.image = [UIImage imageNamed:selectedMagazinePhotoName];
    
    NSLog(@"HomeVC -- Listing the loaded spreadsheet %@", self.selectedMagazineLabel.text);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
/*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Custom Methods

- (IBAction)resetLastRead:(UIBarButtonItem *)sender {
    
    // Show UI Effect
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Last Read Has Been reset"
                                                                   message:@"Now it is like a new install"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    [[NSUserDefaults standardUserDefaults]  setObject:NULL forKey:@"dateKey"];
    
    NSLog(@"HomeVC -- LastReadReset to NULL");
}

@end