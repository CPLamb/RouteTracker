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
#import "AppDelegate.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *AppMainLogo;
@property (weak, nonatomic) IBOutlet UILabel *selectedMagazineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedMagazineLogo;

@property (nonnull, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *stopTextField;
@property (weak, nonatomic) IBOutlet UITextField *returnTextField;
@property (weak, nonatomic) IBOutlet UITextField *bundleTextField;
@property (weak, nonatomic) IBOutlet UITextField *copiesTextField;

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
    
    [self calculateTotals:[self selectProperPlistData]];
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

#pragma mark - new home ui caculator
- (NSArray *)selectProperPlistData {
    
    NSString *myFilename = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];
    
    // Alloc/init the fileURL outside the boundaries of switch/case statement
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.memberData loadPlistData];
    
    NSLog(@"HomeVC -- selectProper pList -- Loads fileName %@", myFilename);
    return [NSArray arrayWithArray:delegate.memberData.membersArray];
}


- (void) calculateTotals:(NSArray *)array
{
    NSInteger stops = [array count];
    NSInteger copies = 0;
    NSInteger bundles = 0;
    NSInteger returns = 0;
    
    // loop thru the array & total values
    for (int i=0;i<=stops-1;i++) {
        copies = copies + [[[array objectAtIndex:i] valueForKey:@"Total Quantity to Deliver"] integerValue];
        returns = returns + [[[array objectAtIndex:i] valueForKey:@"Returns"] integerValue];
    }
    bundles = copies/50;
    self.stopTextField.text = [NSString stringWithFormat:@"%ld", stops];
    self.returnTextField.text = [NSString stringWithFormat:@"%ld", returns];
    self.copiesTextField.text = [NSString stringWithFormat:@"%ld", copies];
    self.bundleTextField.text = [NSString stringWithFormat:@"%ld", bundles];
}

@end
