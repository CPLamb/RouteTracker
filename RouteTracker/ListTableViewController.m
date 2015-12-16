//
//  ListTableViewController.m
//  RouteTracker
//
//  Created by Chris Lamb on 12/27/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import "ListTableViewController.h"
#import "MemberListData.h"
#import "SetupTableViewController.h"
#import "AppDelegate.h"

@interface ListTableViewController ()

@property UITextField *returnedTextField;  // Custom tableViewCell properties
@property BOOL delivered;
@property NSIndexPath *selectedMemberPath;

@end

@implementation ListTableViewController

@synthesize mapViewController = _mapViewController;
@synthesize sortSelectionView = _sortSelectionView;

#define TRIM_LENGTH 7

#pragma mark - Lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];

    sortedByDriver = NO;

    memberTableViewCell = [[MemberTableViewCell alloc] init];

    // Initializes Search properties with values
    self.searchString = [NSString stringWithFormat:@"Coffee"];
    self.filteredArray = [NSMutableArray arrayWithCapacity:20];
    self.mySearchBar.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Changes the correct spreadsheet based upon the appDelegate memberData property IF the list is NOT filtered
    NSInteger listFiltered = [[NSUserDefaults standardUserDefaults] integerForKey: @"list_filtered"];
    if (!listFiltered) {
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate.memberData loadPlistData];
        NSLog(@"ListTableVC -- Should reload the dataFile %@", delegate.memberData.description);

        // Makes up the index array & the sorted array for the cells
        [self makeSectionsIndex:delegate.memberData.membersArray];     // self.membersArray
        [self makeIndexedArray:delegate.memberData.membersArray withIndex:self.indexArray];
    }

    //    sortedByDriver = NO;
    memberTableViewCell = [[MemberTableViewCell alloc] init];

    // Reloads the list
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //    NSLog(@"The segue identifier is %@", [segue identifier]);

    // Show Details screen
    if ([[segue identifier] isEqualToString:@"showDetails"]) {
        self.selectedMemberPath = [self.tableView indexPathForCell:sender];
        NSArray *object = [[self.namesArray objectAtIndex:self.selectedMemberPath.section] objectAtIndex:self.selectedMemberPath.row];

        // Sets the detailItem to the selected item
        [[segue destinationViewController] setSelectedIndexPath:self.selectedMemberPath];
        [[segue destinationViewController] setDetailItem:object];
    }

    // Show Map screen
    if ([[segue identifier] isEqualToString:@"showMap"]) {
        //        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //       NSArray *object = [[self.namesArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

        // Sets the detailItem to the selected item
        [[segue destinationViewController] setMapAnnotations:self.namesArray]; // self.namesArray
    }

    // Show Sort Selection screen
    if ([[segue identifier] isEqualToString:@"showSortSelection"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - Custom sort & search methods

- (NSArray *)makeSectionsIndex:(NSArray *)arrayOfDictionaries {
    //       NSLog(@"Takes the array of Dictionaries (PList), and creates an index of first letters for use in the tableview");

    // Creates a mutable set to read each letter only once
    NSMutableSet *sectionsMutableSet = [NSMutableSet setWithCapacity:36];

    //Reads each items Name & loads it's first letter into the sections set
    for (int i = 0; i < [arrayOfDictionaries count]; i++) {
        //       NSLog(@"Line %d is working", i);
        NSDictionary *aDictionary = [arrayOfDictionaries objectAtIndex:i];
        // Allows sort by Name or Category or Driver
        if (sortedByCategory) {
            NSString *aCategory = [aDictionary objectForKey:@"Category"];
            if (aCategory.length > 0) {
                [sectionsMutableSet addObject:aCategory];
            }
        } else if (sortedByDriver) {
            NSString *aName = [aDictionary objectForKey:@"Driver"];
            if ([aName length] != 0) {
                //                NSString *aLetter = [aName substringToIndex:6U];
                [sectionsMutableSet addObject:aName];
            }
        } else {
            NSString *aName = [aDictionary objectForKey:@"Name"];
            if (aName.length != 0) {
                NSString *aLetter = [aName substringToIndex:1U];  //uses the first letter of the string
                [sectionsMutableSet addObject:aLetter];
            } else {
                NSLog(@"The line is \n %@", aDictionary);
            }
        }
    }

    // Copies the mutable set into a set & then makes a mutable array of the set
    NSSet *sectionsSet = [NSSet setWithSet:sectionsMutableSet];
    NSMutableArray *sectionsMutableArray = [[sectionsSet allObjects] mutableCopy];

    // Now let's sort the array and make it immutable
    NSArray *sortedArray = [sectionsMutableArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    // Trim the length of the indexes so that they appear as a short index word
    NSArray *anUnsortedArray = [self trimWordLength:sectionsMutableArray];
    self.anArrayOfShortenedWords = [anUnsortedArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    self.indexArray = [NSArray arrayWithArray:sortedArray];
    //    [[NSUserDefaults standardUserDefaults] setObject:self.indexArray forKey:@"drivers_list"];

    //    NSLog(@"The self.indexArray = %@", self.indexArray);
    return self.indexArray;
}

- (NSMutableArray *)trimWordLength:(NSMutableArray *)array {
    //    NSLog(@"Trims the words in this array %@ to display on the index", array);

    NSMutableArray *trimmedArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < ([array count]); i++) {
        NSString *trimmedWord = [array objectAtIndex:i];
        if (trimmedWord.length > TRIM_LENGTH) {
            trimmedWord = [trimmedWord substringToIndex:7U];
        }
        [trimmedArray addObject:trimmedWord];
    }

    //    NSLog(@"Trimmed words are; %@", trimmedArray);
    return trimmedArray;
}


- (NSArray *)makeIndexedArray:(NSArray *)wordsArray withIndex:(NSArray *)indexArray {
    //      NSLog(@"Takes an array of index letters (sections) and name array (rows) for display in the indexed tableview");
    //      NSLog(@"wordsArray is %@", wordsArray);

    // Create the mutable array
    NSMutableArray *indexedNameArray = [NSMutableArray arrayWithCapacity:600];

    // Create an indexed array start with the first index letter
    for (int i=0; i <=([indexArray count] - 1); i++) {
        NSString *theIndexItem = [indexArray objectAtIndex:i];
        NSMutableArray *aListOfItems = [NSMutableArray arrayWithCapacity:50];

        // Now page thru all of the names
        for (int j=0; j<=([wordsArray count]-1); j++) {
            // sorts by Name or Category
            NSString *firstLetterOfWord = [[NSString alloc] init];
            if (sortedByCategory) {
                firstLetterOfWord = [[wordsArray objectAtIndex:j] objectForKey:@"Category"];
            } else if (sortedByDriver) {
                firstLetterOfWord = [[wordsArray objectAtIndex:j] objectForKey:@"Driver"];
                if ([[[wordsArray objectAtIndex:j] objectForKey:@"Driver"] length] == 0) {
                    firstLetterOfWord = @"XXX";
                }
            } else {
                if ([[[wordsArray objectAtIndex:j] objectForKey:@"Name"] length] != 0) {
                    firstLetterOfWord = [[[wordsArray objectAtIndex:j] objectForKey:@"Name"] substringToIndex:1U];
                }
            }
            if ([theIndexItem isEqualToString:firstLetterOfWord]) {
                [aListOfItems addObject:[wordsArray objectAtIndex:j]];
            }
            //            NSLog(@"i & j = %d %d %lu", i, j, (unsigned long)[wordsArray count]);
        }
        //        NSArray *aListOfSortedItems = [aListOfItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [indexedNameArray addObject:aListOfItems];
    }
    self.namesArray = [NSMutableArray arrayWithArray:indexedNameArray];
    //        NSLog(@"ListViewTableController self.namesArray = %@", self.namesArray);

    return self.namesArray;
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    // Update the filtered array based on the search text & scope

    [self.filteredArray removeAllObjects];      // First clear thefiltered array

    //Loop thru each defined field and looks for a match
    for (int i=0; i<+[self.membersArray count]-1; i++) {
        NSString *searchName = [[self.membersArray objectAtIndex:i] objectForKey:@"Name"];
        NSString *searchDriver = [[self.membersArray objectAtIndex:i] objectForKey:@"Driver"];
        NSString *searchCategory = [[self.membersArray objectAtIndex:i] objectForKey:@"Category"];

        // Checks for an empty search string
        if (self.searchString.length > 0) {

            // Searches in the various fields for the string match
            BOOL foundInName = [searchName rangeOfString:self.searchString options:NSCaseInsensitiveSearch].location == NSNotFound;
            BOOL foundInDriver = [searchDriver rangeOfString:self.searchString options:NSCaseInsensitiveSearch].location == NSNotFound;
            BOOL foundInCategory = [searchCategory rangeOfString:self.searchString options:NSCaseInsensitiveSearch].location == NSNotFound;
            if (!foundInName || !foundInDriver || !foundInCategory) {
                NSLog(@"The Business is #%d %@   %@", i, searchName, self.searchString);

                [self.filteredArray addObject:[self.membersArray objectAtIndex:i]];
            }
        }
    }
    //    NSLog(@"The resulting filteredArray has %d items", [self.filteredArray count]);

    // Makes sure there is something in the filteredArray
    if ([self.filteredArray count] > 0) {
        // Copy to namesArray and reload the data
        self.namesArray = [NSMutableArray arrayWithArray:self.filteredArray];

        // Reworks the index & cells
        [self makeSectionsIndex:self.namesArray];
        [self makeIndexedArray:self.namesArray withIndex:self.indexArray];


        MEMBERLISTDATA.namesArray = [NSArray arrayWithArray:self.namesArray];

        [self.tableView reloadData];

        //Loads up the annotation pins for the BigMap
        self.mapViewController.mapAnnotations = [[NSMutableArray alloc] initWithArray:self.namesArray];
        NSLog(@"Loaded %lu pins", (unsigned long)[self.namesArray count]);
    }
    // sets the global BOOL list_filtered to 1
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"list_filtered"];

}

#pragma mark - UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    self.searchString = self.mySearchBar.text;
    //    NSLog(@"TRYing to search Now for ---> %@", self.searchString);

    [self filterContentForSearchText:self.searchString scope:@"All"];

    //    NSLog(@"Now we're SEARCHING baby!");
    self.navigationItem.title = [NSString stringWithFormat:@"%@'s route", self.searchString];
    [self.mySearchBar resignFirstResponder];            // dismisses the keyboard

    // sets the global BOOL list_filtered to TRUE
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"list_filtered"];

}
/*
 - (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
 NSString *searchString = self.mySearchBar.text;
 NSLog(@"TRYing to search Now for this %@'s Route", searchString);
 }
 */
#pragma mark - Custom methods

- (void)buildDriversList
{
    // [self.driversArray removeAllObjects];
    NSMutableSet *driversListSet = [[NSMutableSet alloc] init];
    for (int i = 0; i <= [self.membersArray count] - 1; i++) {

        if ([[[self.membersArray objectAtIndex:i] objectForKey:@"Driver"] length] > 0) {
            // The set only accepts one instance of each driver
            [driversListSet addObject:[[self.membersArray objectAtIndex:i] objectForKey:@"Driver"]];
        }

    }

    self.driversArray = [NSMutableArray arrayWithArray:[driversListSet allObjects] ];

    NSLog(@"ListTableVC -- The driversList is %@", self.driversArray);

    [[NSUserDefaults standardUserDefaults] setObject:self.driversArray forKey:@"drivers_list"];
}

- (NSString *)selectProperPlistData {

    NSString *myFilename = [[NSUserDefaults standardUserDefaults] stringForKey:@"selected_spreadsheet"];

    // Alloc/init the fileURL outside the boundaries of switch/case statement
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.memberData loadPlistData];

    NSLog(@"ListTableVC -- selectProper pList -- Loads fileName %@", myFilename);
    return myFilename;
}

- (void)loadLocalPlistData {
    // Loads the Plist into member array either from web or locally

    // Loads file locally
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *resourceFilename = [self selectProperPlistData];
    NSURL *fileURL = [mainBundle URLForResource:resourceFilename  withExtension:@"plist"];
    // NSURL *fileURL = [mainBundle URLForResource:@"SCWaveDistributionList" withExtension:@"plist"];


    self.membersArray = [NSArray arrayWithContentsOfURL:fileURL];
    NSLog(@"Array count %lu", (unsigned long)[self.membersArray count]);

    // Recalculates the driversArray and assigns it to NSUserDefaults
    // self.driversArray = [NSArray arrayWithObjects:@"Bill", @"CPL", @"Mick", nil];
    [self buildDriversList];

    [[NSUserDefaults standardUserDefaults] setObject:self.driversArray forKey:@"drivers_list"];

    // Reloads the tableView
    [self.tableView reloadData];

    // loads the web Plist on another thread
    //   [self loadPlistURL];
}


#pragma mark - Delegate methods

- (void)fieldFilter:(SortSelectionViewController *)controller
{
    NSString *selectedDriver = [[NSUserDefaults standardUserDefaults] objectForKey:@"selected_driver"];
    NSLog(@"Filtering by driver %@", selectedDriver);
}

- (void)dataFileSelect:(SetupTableViewController *)controller
{
    NSLog(@"Changing the data file!!");
    [self selectProperPlistData];
}

- (IBAction)sortListButton:(UIBarButtonItem *)sender {
    //    NSLog(@"Displays the sort selection view - 'slide up' animation");

    self.sortSelectionView.hidden = NO;
    [UIView animateWithDuration:1.5 animations:^{
        self.sortSelectionView.alpha = 0.85;
    }];
}

- (void)cancelSortView:(SortSelectionViewController *)controller
{
    NSLog(@"This is the delegate (MasterVC) responding with %@", controller);

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)nameSort:(SortSelectionViewController *)controller {
    NSLog(@"Sorts the table by name");

    // Initialization
    sortedByCategory = NO;

    self.namesArray = [NSMutableArray arrayWithArray:self.membersArray];

    // Reworks the index & cells
    [self makeSectionsIndex:self.namesArray];
    [self makeIndexedArray:self.namesArray withIndex:self.indexArray];

    // Store new filtered data in the central data object
    MEMBERLISTDATA.namesArray = [NSArray arrayWithArray:self.namesArray];

    // Regenerate the data
    [self.tableView reloadData];

    // Removes the view controller
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)categorySort:(SortSelectionViewController *)controller {
    NSLog(@"Sorts the table by category");

    // Initialization
    sortedByCategory = YES;
    sortedByDriver = NO;
    //    self.sortSelectionView.alpha = 0.0;
    self.namesArray = [NSMutableArray arrayWithArray:self.membersArray];

    // Reworks the index & cells
    [self makeSectionsIndex:self.namesArray];
    [self makeIndexedArray:self.namesArray withIndex:self.indexArray];

    // Store new filtered data in the central data object
    MEMBERLISTDATA.namesArray = [NSArray arrayWithArray:self.namesArray];

    // Regenerate the data
    [self.tableView reloadData];

    // Removes the view controller
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)driverSort:(SortSelectionViewController *)controller {
    NSLog(@"ListTableVC - Sorts the table by driver");

    // reload data
    [self loadLocalPlistData];

    // Initialization
    sortedByDriver = YES;
    sortedByCategory = NO;
    //    self.sortSelectionView.alpha = 0.0;

#pragma mark - TODO - this is where the problem lies, me thinks?
      self.namesArray = [NSMutableArray arrayWithArray:self.membersArray];

    // Reworks the index & cells
    [self makeSectionsIndex:self.namesArray];
    [self makeIndexedArray:self.namesArray withIndex:self.indexArray];

    [[NSUserDefaults standardUserDefaults] setObject:self.indexArray forKey:@"drivers_list"];
    NSLog(@"%@", self.indexArray);
    // Store new filtered data in the central data object
    //    MEMBERLISTDATA.namesArray = [NSArray arrayWithArray:self.namesArray];

    // Regenerate the data
    [self.tableView reloadData];

    // Removes the view controller
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return [self.indexArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [[self.namesArray objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MemberCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // Configure the cell text fields
    cell.textLabel.text = [[[self.namesArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"];      // for subclass cell memberTableViewCell.title.text

    NSString *subtitleDeliver = [[[self.namesArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Total Quantity to Deliver"];
    //    NSString *subtitleDelivered = [[[self.namesArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Delived to Date"];

    NSString *subtitleDriver = [[[self.namesArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Driver"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Deliver: %@       Driver: %@", subtitleDeliver, subtitleDriver];

    //    self.tempIndexPath = indexPath;
    //    NSLog(@"cell data %@", [[[self.namesArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]);
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return [self.indexArray objectAtIndex:section];
}

-  (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {

    return self.anArrayOfShortenedWords;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {

    return index;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

@end
