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

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *selectedMagazine;
@property (weak, nonatomic) IBOutlet UIImage *selectedMagazineLogo;
@end

@implementation HomeViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *dataFilenameIndex = [[NSUserDefaults standardUserDefaults]stringForKey:@"selected_plist"];

    NSLog(@"HomeVC -- dataFilenameIndex = %@", dataFilenameIndex.description);

// Sets up display of magazine loaded
    self.selectedMagazine.text = dataFilenameIndex.description;

    NSLog(@"HomeVC -- Listing the loaded spreadsheet %@", self.selectedMagazine.text);
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
