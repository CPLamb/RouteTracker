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
    _title = [memberData objectForKey:@"Name"];
    _subTitle = [memberData objectForKey:@"Driver"];
    hasShop = [[memberData objectForKey:@"hasShop"] boolValue];

    return self;
}


@end
