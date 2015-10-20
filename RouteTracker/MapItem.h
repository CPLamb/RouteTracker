//
//  MapItem.h
//  ThinkLocalFirst
//
//  Created by Chris Lamb on 4/21/13.
//  Copyright (c) 2013 Chris Lamb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapItem : NSObject <MKAnnotation> {
    NSNumber *latitude;
    NSNumber *longitude;
    BOOL hasShop;
}

@property (nonatomic, strong) NSDictionary* memberData;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D )location placeName:(NSString *)placeName description:(NSString *)description;
- (id)initWithCoordinates:(CLLocationCoordinate2D )location memberData:(NSDictionary *)memberData;

@end
