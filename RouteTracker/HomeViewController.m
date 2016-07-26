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
#import "MapKitViewController.h"
#import "ListTableViewController.h"
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
@property (weak, nonatomic) IBOutlet UIScrollView *homeScrollView;
@property (weak, nonatomic) IBOutlet UILabel *routeSelectedLabel;

@property (copy, nonnull, nonatomic) NSString* searchString;
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
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UITabBarController *c = (UITabBarController *)delegate.window.rootViewController;
    UINavigationController *nav = c.viewControllers[1];
    MapKitViewController *map = nav.viewControllers.firstObject;
    [map addNotification];
    nav = c.viewControllers[2];
    ListTableViewController *list = nav.viewControllers.firstObject;
    [list addNotification];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newSearchFromList:) name:kListTableStartNewSearchNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routerPickerValueChange:) name:kRouterPickerValueChangeNotification object:nil];
    // init search string = nil
    // search string can only set by notification from list view controller
    // if it have been set, new filter will be enabled.
    _searchString = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *selectedDriver = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedDriver"];
    if (selectedDriver) {
        if ([selectedDriver isEqualToString:@"All"]) {
            self.searchString = @"";
        } else {
            self.searchString = selectedDriver;
        }
        self.routeSelectedLabel.text = selectedDriver;
    }
    
    NSString *dataFilenameIndex = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_plist"];
    
    NSLog(@"HomeVC -- dataFilenameIndex = %@", dataFilenameIndex.description);
    
    // Sets up display of magazine loaded
    self.selectedMagazineLabel.text = dataFilenameIndex.description;
    
    NSString *selectedMagazinePhotoName = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_photo"];
    
    self.selectedMagazineLogo.image = [UIImage imageNamed:selectedMagazinePhotoName];
    
    NSLog(@"HomeVC -- Listing the loaded spreadsheet %@", self.selectedMagazineLabel.text);
    
//    if (_searchString != nil) {

    [self calculateTotals:[self selectProperPlistData]];
//    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGFloat height = _homeScrollView.frame.size.height > 516.0f ?
    _homeScrollView.frame.size.height + 1.0f : 516.0f;
    _homeScrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
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

- (void)newSearchFromList: (NSNotification *)notification {
    if (notification.object) {
        [self changeSearchString:notification.object];
    }
}

- (void)routerPickerValueChange: (NSNotification *)notification {
    if (notification.object) {
        _searchString = nil;
        if ([notification.object isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *) notification.object;
            _stopTextField.text = arr[0];
            _returnTextField.text = arr[1];
            _copiesTextField.text = arr[2];
            _bundleTextField.text = arr[3];
            
            _routeSelectedLabel.text = arr[4];
            
            if (_routeSelectedLabel.text.length <= 0 || [_routeSelectedLabel.text isEqualToString:@"All"]) {
                _routeSelectedLabel.text = @"All";
            }
        }
    }
}

- (void) changeSearchString: (NSObject *)searchString {
    if ([searchString isKindOfClass:[NSString class]]) {
        _searchString = (NSString *) searchString;
    } else {
        return;
    }
    
    _routeSelectedLabel.text = _searchString;
    
    if (_searchString.length <= 0) {
        _routeSelectedLabel.text = @"All";
    }
}

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
    
    NSArray *array = [NSArray arrayWithArray:delegate.memberData.membersArray];
    
    NSLog(@"HomeVC -- selectProper pList -- Loads fileName %@", myFilename);
    if (_searchString != nil && _searchString.length > 0) {
        NSLog(@"Before filter has %ld count", array.count);
        NSMutableArray *filterArray = [NSMutableArray new];
        
        for (int i=0; i<+[array count]-1; i++) {
            NSString *searchName = [[array objectAtIndex:i] objectForKey:@"Name"];
            NSString *searchDriver = [[array objectAtIndex:i] objectForKey:@"Driver"];
            NSString *searchCategory = [[array objectAtIndex:i] objectForKey:@"Category"];
            
            BOOL foundInName = [searchName rangeOfString:_searchString options:NSCaseInsensitiveSearch].location == NSNotFound;
            BOOL foundInDriver = [searchDriver rangeOfString:_searchString options:NSCaseInsensitiveSearch].location == NSNotFound;
            BOOL foundInCategory = [searchCategory rangeOfString:_searchString options:NSCaseInsensitiveSearch].location == NSNotFound;
            if (!foundInName || !foundInDriver || !foundInCategory) {
                [filterArray addObject:[array objectAtIndex:i]];
            }
        }
        
        NSLog(@"after filter has %ld count", filterArray.count);
        _searchString = nil;
        return [NSArray arrayWithArray:filterArray];
    } else {
        _searchString = nil;
        return array;
    }
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
    NSInteger cb = [[NSUserDefaults standardUserDefaults] integerForKey:@"copies_bundle"];
    bundles = copies/cb;
    _stopTextField.text = [NSString stringWithFormat:@"%ld", stops];
    _returnTextField.text = [NSString stringWithFormat:@"%ld", returns];
    _copiesTextField.text = [NSString stringWithFormat:@"%ld", copies];
    _bundleTextField.text = [NSString stringWithFormat:@"%ld", bundles];
}

@end
