//
//  MapKitViewController.h
//  CutThroatRobotics
//
//  Created by Chris Lamb on 12/8/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapKitViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *mapAnnotations;
@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) id<MKAnnotation> defaultPin;
@property (nonatomic) MKCoordinateRegion centerRegion;
@property (strong, nonatomic) CLLocation *referenceLocation;
@property (nonatomic, readonly) NSArray* pinsArray;

- (IBAction)turnByRouting:(UIBarButtonItem *)sender;

@end
