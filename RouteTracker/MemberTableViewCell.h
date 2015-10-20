//
//  MemberTableViewCell.h
//  RouteTracker
//
//  Created by Chris Lamb on 12/30/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//
/*
 Used to allow Custom formatting of the tableViewCell.  This let's
 you assign dynamic labels to the cells
*/

#import <UIKit/UIKit.h>

@interface MemberTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *date;

@end
