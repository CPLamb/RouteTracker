//
//  SortSelectionViewController.m
//  ThinkLocalFirst
//
//  Created by Chris Lamb on 5/6/13.
//  Copyright (c) 2013 Chris Lamb. All rights reserved.
//

#import "SortSelectionViewController.h"

@interface SortSelectionViewController ()

@end

@implementation SortSelectionViewController
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods

- (IBAction)cancelButton:(UIButton *)sender {
    NSLog(@"Cancel Button pressed %@", sender);
    
    [self.delegate cancelSortView:self];
    
    // sets the global BOOL list_filtered to 0
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"list_filtered"];
}

- (IBAction)sortByCategory:(UIButton *)sender {
 //   NSLog(@"Category Button pressed %@", sender);
    
    [self.delegate categorySort:self];
}

- (IBAction)sortByName:(UIButton *)sender {
    
    [self.delegate nameSort:self];
    
// sets the global BOOL list_filtered to 0
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"list_filtered"];
// sets up a zoom 'extents' of the map
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"initial_filter"];

}

- (IBAction)sortByDriver:(UIButton *)sender {
    
    [self.delegate driverSort:self];
}

@end
