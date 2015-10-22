//
//  HomeViewController.m
//  RouteTracker
//
//  Created by Chris Lamb on 1/6/15.
//  Copyright (c) 2015 com.SantaCruzNewspaperTaxi. All rights reserved.
//

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
    int dataFilenameIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_spreadsheet"];
    NSLog(@"dataFilenameIndex = %d", dataFilenameIndex);
// Sets up display of magazine loaded
    switch(dataFilenameIndex) {
        case 0:
            self.selectedMagazine.text = @"SCWaveDistributionListCurrent";
            self.selectedMagazineLogo = [UIImage imageNamed:@"SCWavesSantaLogo.png"];
            break;
        case 1:
            self.selectedMagazine.text = @"MontereyWaveDistributionList";
            self.selectedMagazineLogo = [UIImage imageNamed:@"EMBLogo.png"];
           break;
    }
    NSLog(@"Listing the loaded spreadsheet %@", self.selectedMagazine.text);

  
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


@end
