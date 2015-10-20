//
//  ListTableViewController.h
//  RouteTracker
//
//  Created by Chris Lamb on 12/27/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SortSelectionViewController.h"
#import "MemberTableViewCell.h"
#import "MemberListData.h"
#import "MapKitViewController.h"
#import "SetupTableViewController.h"

@interface ListTableViewController : UITableViewController <UITextFieldDelegate, SortSelectionViewControllerDelegate, SetupTableViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    BOOL sortedByCategory;
    BOOL sortedByDriver;
    MemberTableViewCell *memberTableViewCell;
    
}
@property (nonatomic, strong) MemberListData *memberListAll;
@property (strong, nonatomic) id detailItem;    

@property (nonatomic, strong) NSArray *membersArray;    // Master array of dictionaries from the PList
@property (strong, nonatomic) NSMutableArray *namesArray;      // Name of each member object By Letter
@property (strong, nonatomic) NSArray *indexArray;      // Letters used for sections index
@property (strong, nonatomic) NSArray *anArrayOfShortenedWords;
@property (strong, nonatomic) NSMutableArray *driversArray;

@property (nonatomic, strong) IBOutlet UISearchBar *mySearchBar;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSMutableArray *filteredArray;

@property (nonatomic, strong) MapKitViewController *mapViewController;

@property (weak, nonatomic) IBOutlet UIView *sortSelectionView; //TODO: delete?
@property (weak, nonatomic) IBOutlet UILabel *sender;

// @property (weak, nonatomic) MemberTableViewCell *memberTableViewCell;  // subclassed to add different labels to each cell

- (IBAction)sortListButton:(UIBarButtonItem *)sender;

- (IBAction)hideButton:(UIButton *)sender;
- (IBAction)deliveredButton:(UIButton *)sender;
- (IBAction)showDetailsButton:(UIButton *)sender;

@end
