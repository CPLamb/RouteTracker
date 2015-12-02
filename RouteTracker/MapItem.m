//
//  MapItem.m
//  ThinkLocalFirst
//
//  Created by Chris Lamb on 4/21/13.
//  Copyright (c) 2013 Chris Lamb. All rights reserved.
//

#import "MapItem.h"
#include <stdlib.h>


#define HOME_LAT 36.96805
#define HOME_LONG -121.9987

@implementation MapItem
@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize memberData = _memberData;

#pragma mark Overidden getter

- (CLLocationCoordinate2D)coordinate {
    //    double rlat = (double)(rand() % 1000 - 500)/30000.0;
    //    double rlong = (double)(rand() % 1000 - 500)/30000.0;
    double lat = [_latitude doubleValue];
    double lon = [_longitude doubleValue];
    
    //    NSLog(@"Coords are %3.3f %3.3f", lat, lon);
    return CLLocationCoordinate2DMake(lat, lon);
}

- (id)initWithCoordinates:(CLLocationCoordinate2D )location placeName:(NSString *)placeName description:(NSString *)description {
    _latitude = [NSNumber numberWithDouble:location.latitude];
    _longitude = [NSNumber numberWithDouble:location.longitude];
    _title = placeName;
    _subTitle = description;
    
    return self;
}

- (id)initWithCoordinates:(CLLocationCoordinate2D)location memberData:(NSDictionary *)memberData {
    _latitude = [NSNumber numberWithDouble:location.latitude];
    _longitude = [NSNumber numberWithDouble:location.longitude];
    
// Temporary patch to display Qty & Driver on annotation title FIX is adding a 2nd line to the annotation
    NSString *nameString;
    if ([[memberData objectForKey:@"Name"] length] > 13) {
        nameString = [[[memberData objectForKey:@"Name"] substringToIndex:13U] stringByAppendingString:@" "];
    } else {
        nameString = [[memberData objectForKey:@"Name"] stringByAppendingString:@" "];
    }
    NSString *deliveredString = @"0";
    if ([[memberData objectForKey:@"Delivered to Date"] length] == 0) {
        deliveredString = @"0/";
    } else {
        deliveredString = [[memberData objectForKey:@"Delivered to Date"] stringByAppendingString:@"/"];
    }
    NSString *qtyString = [[memberData objectForKey:@"Total Quantity to Deliver"]stringByAppendingString:@" "];
    NSString *driverString = [[memberData objectForKey:@"Driver"] substringToIndex:3U];
    
    _title = [[[nameString stringByAppendingString:deliveredString] stringByAppendingString:qtyString] stringByAppendingString:driverString];
//    _title = [memberData objectForKey:@"Name"];
    
    _subTitle = [memberData objectForKey:@"Driver"];
    hasShop = [[memberData objectForKey:@"hasShop"] boolValue];

    return self;
}


@end
