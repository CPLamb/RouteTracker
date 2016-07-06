//
//  MapKitViewController.m
//  CutThroatRobotics
//
//  Created by Chris Lamb on 12/8/14.
//  Copyright (c) 2014 com.SantaCruzNewspaperTaxi. All rights reserved.
//

#import "MapKitViewController.h"
#import "MapItem.h"
#import "NoShopAnnotation.h"
#import "MemberListData.h"
#import "AppDelegate.h"

@interface MapKitViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MapKitViewController

@synthesize mapAnnotations = _mapAnnotations;

const float MIN_MAP_ZOOM_METERS = 1500.0;
const float MAX_MAP_ZOOM_METERS = 75000.0;
const float DEFAULT_SPAN = 10000.0;
const float DEFAULT_DETAIL_SPAN = 5000.0;
const int  MAX_PINS_TO_DROP = 200;

#pragma mark - Lifecycle Methods

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@ view did load for the first time.", self);
    
    // ** Don't forget to add NSLocationWhenInUseUsageDescription in MyApp-Info.plist and give it a string
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterNewDetail:) name:kListTableStartNewDetailNotification object:nil];
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    // Setup for the mapView
    self.mapView.showsUserLocation = false;
    [self.mapView setDelegate:self];            // set by storyboard
    //    CLLocationDegrees theLatitude = 36.9665;
    //    CLLocationDegrees theLongitude = -122.0237;
    //    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(theLatitude, theLongitude), MKCoordinateSpanMake(0.5, 0.5)) animated:YES];
    self.mapView.mapType = MKMapTypeStandard;
    
    // Setup for the annotations & drop a pin at home
    self.mapAnnotations = [[NSMutableArray alloc] init];
    
    // Loads from data objects
    [self loadPins];
    
    [self enable3DMapping];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@ view WILL appear...", self);
    
    // Changes map type based on setup map control
    NSInteger mapType = [[NSUserDefaults standardUserDefaults] integerForKey:@"selected_map_type"];
    switch(mapType) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
    }
    
    // Changes the correct spreadsheet based upon the appDelegate memberData property IF the list is NOT filtered
    NSInteger listFiltered = [[NSUserDefaults standardUserDefaults] integerForKey: @"list_filtered"];
    if (!listFiltered) {
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate.memberData loadPlistData];
        //      [self loadPins];
    }
    
    // Loads from data objects
    //    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //    [delegate.memberData loadPlistData];
    
    NSInteger detailFiltered = [[NSUserDefaults standardUserDefaults] integerForKey: @"list_detail"];
    if (!detailFiltered) {
        [self loadPins];
    }
    
    /*NSInteger initialFilter = [[NSUserDefaults standardUserDefaults] integerForKey: @"initial_filter"];
    // Centers the view on the box containing all visible pins THIS prevents initial zoom
    if (!initialFilter) {
        [self calculateCenter];
    }*/
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@ DID appear...", self);
    
    //    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //    [delegate.memberData loadPlistData];
    NSInteger detailFiltered = [[NSUserDefaults standardUserDefaults] integerForKey: @"list_detail"];
    if (!detailFiltered) {
        if (self.currentRect.size.width != 0) {
            [self.mapView setVisibleMapRect:self.currentRect animated:YES];
        } else {
            [self.mapView setRegion:self.centerRegion animated:YES];
        }
        
        // Limit the total number pins to drop to MAX_PINS_TO_DROP so that map view is not too cluttered
        NSLog(@"Pins in the select = %lu", (unsigned long)[self.mapAnnotations count]);
        
        [self.mapView addAnnotations:self.mapAnnotations];
        
        // Centers the view on the box containing all visible pins
        [self calculateCenter];
    }
    
    /*NSInteger initialFilter = [[NSUserDefaults standardUserDefaults] integerForKey: @"initial_filter"];
    // Centers the view on the box containing all visible pins THIS overrides persistant zoom
    if (initialFilter) {
        [self calculateCenter];
    }*/
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.currentRect = self.mapView.visibleMapRect;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"initial_filter"];
}

#pragma mark - Navigation segue method

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NoShopAnnotation *)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Sets the detailItem to the selected item
    [[segue destinationViewController] setDetailItem:sender.memberData];
}

#pragma mark - Custom Methods

- (void) enterNewDetail: (NSNotification *) notification {
    if ([notification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = notification.object;
        [self loadDetailPin:dict];
    }
}

- (void)enable3DMapping  //partial implementationof 3D mapping!!!!
{
    //Blog Post - http://nscookbook.com/2013/10/ios-programming-recipe-30-using-3d-mapping/
    //Set a few MKMapView Properties to allow pitch, building view, points of interest, and zooming.
    self.mapView.pitchEnabled = YES;
    self.mapView.showsBuildings = YES;
    self.mapView.showsPointsOfInterest = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    
    //set up initial location
    CLLocationCoordinate2D ground = CLLocationCoordinate2DMake(40.6892, -74.0444);
    CLLocationCoordinate2D eye = CLLocationCoordinate2DMake(40.6892, -74.0442);
    MKMapCamera *mapCamera = [MKMapCamera cameraLookingAtCenterCoordinate:ground
                                                        fromEyeCoordinate:eye
                                                              eyeAltitude:50];
    self.mapView.camera = mapCamera;
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //  NSLog(@"%@", [locations lastObject]);
}

- (void)calculateCenter {
    
    // set min to the highest and max to the lowest so any MIN or MAX calculation will change this value
    CLLocationCoordinate2D minCoord = CLLocationCoordinate2DMake(180.0, 180.0);
    CLLocationCoordinate2D maxCoord = CLLocationCoordinate2DMake(-180.0, -180.0);
    
    NSLog(@"Checking min/max coords for %lu mapAnnotations", (unsigned long)[self.mapAnnotations count]);
    
    // checks all annotations for min and max (deprecated -- checking pinsArray instead)
    // in case multi thread crash. use a array to replace mutable array.
    NSArray *mapArray = [NSArray arrayWithArray:self.mapAnnotations];
    
    for (MapItem * item in mapArray){
        if ((item.latitude != 0) && (item.longitude != 0)) {
            double lat = [item.latitude doubleValue];
            double lon = [item.longitude doubleValue];
            minCoord.latitude = MIN(minCoord.latitude, lat);
            minCoord.longitude = MIN(minCoord.longitude, lon);
            maxCoord.latitude = MAX(maxCoord.latitude, lat);
            maxCoord.longitude = MAX(maxCoord.longitude, lon);
        }
    }
    mapArray = nil;
    
    // after checking all
    if((self.mapView.userLocation.coordinate.latitude != 0.0) && (self.mapView.userLocation.coordinate.latitude != 0.0)) {
        CLLocationCoordinate2D userCoord = self.referenceLocation.coordinate;
        minCoord.latitude = MIN(minCoord.latitude, userCoord.latitude);
        minCoord.longitude = MIN(minCoord.longitude, userCoord.longitude);
        maxCoord.latitude = MAX(maxCoord.latitude, userCoord.latitude);
        maxCoord.longitude = MAX(maxCoord.longitude, userCoord.longitude);
    }
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((minCoord.latitude + maxCoord.latitude)/2, (minCoord.longitude + maxCoord.longitude)/2);
    
    // Initializes distance at DEFAULT_SPAN if both coordinates are the same
    float distance;
    if ((minCoord.latitude == maxCoord.latitude) && (maxCoord.longitude == maxCoord.longitude)) {
        distance = DEFAULT_SPAN;
    } else {
        
        CLLocation *minLocationLat = [[CLLocation alloc] initWithLatitude:minCoord.latitude longitude:minCoord.longitude];
        CLLocation *maxLocationLat = [[CLLocation alloc] initWithLatitude:maxCoord.latitude longitude:minCoord.longitude];
        
        CLLocation *minLocationLong = [[CLLocation alloc] initWithLatitude:minCoord.latitude longitude:minCoord.longitude];
        CLLocation *maxLocationLong = [[CLLocation alloc] initWithLatitude:minCoord.latitude longitude:maxCoord.longitude];
        
        double distanceLat = ceil([minLocationLat distanceFromLocation:maxLocationLat]);
        double distanceLong = ceil([minLocationLong distanceFromLocation:maxLocationLong]);
        
        if (ceil(distanceLong - distanceLat) > 1000000) {
            distance = distanceLat > distanceLong ? distanceLat : distanceLong;
        } else {
            distance = sqrt(distanceLat * distanceLat + distanceLong * distanceLong) * 0.65f;
            distance = distance * 1.1;      //provides a better overall view
        }
        
        NSLog(@"distance difference = %f, long = %f, lat = %f, ", distanceLong - distanceLat, distanceLong, distanceLat);
        //
    }
    
    self.centerRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, distance, distance);
    [self.mapView setRegion:self.centerRegion animated:true];
}

- (IBAction)turnByRouting:(UIBarButtonItem *)sender
{
    NSLog(@"Opens the native Map app's turn-by-turn navigation");
    
    //business location
    // test location
    //    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(36.9793,-121.9985);
    
    NSString *latitude = [[self.pinsArray objectAtIndex:0] objectForKey:@"Latitude"];
    NSString *longitude = [[self.pinsArray objectAtIndex:0] objectForKey:@"Longitude"];
    
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    
    MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:coords addressDictionary:nil];
    MKMapItem *mapItemDestination = [[MKMapItem alloc]initWithPlacemark:place];
    
    //current location
    MKMapItem *mapItemCurrent = [MKMapItem mapItemForCurrentLocation];
    
    NSArray *mapItems = @[mapItemCurrent, mapItemDestination];
    
    NSDictionary *options = @{
                              MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                              MKLaunchOptionsMapTypeKey:[NSNumber numberWithInteger:MKMapTypeStandard],
                              MKLaunchOptionsShowsTrafficKey:@YES
                              };
    [MKMapItem openMapsWithItems:mapItems launchOptions:options];
    
}

// Getter function checks to see if user location is enabled & if not zooms to CPL Labs location
- (CLLocation*)referenceLocation {
    if( _referenceLocation == nil ){
        CLLocationCoordinate2D userCoord = self.mapView.userLocation.location.coordinate;
        if( self.mapView.userLocation.location == nil ||
           (userCoord.latitude == 0.0 && userCoord.longitude == 0.0) ){
            // If user location can't be found, fake it
            //            userCoord = CLLocationCoordinate2DMake(36.9665, -122.0237);
        } else {
            _referenceLocation = self.mapView.userLocation.location;
        }
    }
    return _referenceLocation;
}

#pragma mark - Custom Annotation methods
/*
 - (NSArray*)pinsArray {
 NSMutableArray *pinsArray = [NSMutableArray array];
 
 // If a single detailItem is set, prefer that to the list of all pins
 if (self.detailItem != nil) {
 [pinsArray addObject:self.detailItem];
 }
 else {
 // Otherwise show all pins in the namesArray
 for( id arrayOrDict in MEMBERLISTDATA.namesArray ){
 // Flatten any arrays (needed in data for sorting lists with categories)
 if( [arrayOrDict isKindOfClass:[NSArray class]] ){
 [pinsArray addObjectsFromArray:arrayOrDict];
 }
 else {
 [pinsArray addObject:arrayOrDict];
 }
 }
 }
 //    [pinsArray addObject:self.mapView.userLocation];
 
 NSLog(@"ACCESSING pinsArray with count = %lu", (unsigned long)[pinsArray count]);
 return pinsArray;
 }
 */

- (NSArray*)pinsArray {
    NSMutableArray *pinsArray = [NSMutableArray array];
    
    // If a single detailItem is set and if coordinates are non zero, prefer that to the list of all pins
    
    if ([[self.detailItem objectForKey:@"Latitude"] intValue] == 0)
    {
        NSLog(@"It's empty be-atch");
    }
    
    if ((self.detailItem != nil) && !([[self.detailItem objectForKey:@"Latitude"]  isEqual: @" "]||[[self.detailItem objectForKey:@"Longitude"]  isEqual: @" "]))
    {
        [pinsArray addObject:self.detailItem];
    } else {
        // Otherwise show all pins in the namesArray
        for( id arrayOrDict in MEMBERLISTDATA.namesArray ){
            // Flatten any arrays (needed in data for sorting lists with categories)
            if( [arrayOrDict isKindOfClass:[NSArray class]] ){
                [pinsArray addObjectsFromArray:arrayOrDict];
            } else {
                [pinsArray addObject:arrayOrDict];
            }
        }
    }
    
    //    [pinsArray addObject:self.mapView.userLocation];
    
    NSLog(@"ACCESSING pinsArray with count = %lu", (unsigned long)[pinsArray count]);
    return pinsArray;
}


- (void)loadDetailPin: (NSDictionary *)detailDict {
    [self removeAllPins:nil];
    
    for(NSDictionary *dict in self.pinsArray){
        if ([self dictionary:dict isEqualTo:detailDict]) {
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"list_detail"];
            NSString *aLatitudeString = [dict objectForKey:@"Latitude"];
            NSString *aLongitudeString = [dict objectForKey:@"Longitude"];
            double aLatitude = [aLatitudeString doubleValue];
            double aLongitude = [aLongitudeString doubleValue];
            CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(aLatitude, aLongitude);
            NoShopAnnotation *aNewPin = [[NoShopAnnotation alloc] initWithCoordinates:coordinates memberData:dict];
            aNewPin.memberData = dict;
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinates, DEFAULT_DETAIL_SPAN, DEFAULT_DETAIL_SPAN);
            [self.mapView setRegion:region animated:true];
            [self.mapView addAnnotation:aNewPin];
            
            return;
        }
    }
}

- (BOOL)dictionary: (NSDictionary *)dict isEqualTo: (NSDictionary *)detailDict {
    return detailDict[@"Advertiser Color"] == dict[@"Advertiser Color"] &&
    detailDict[@"Contact Name"] == dict[@"Contact Name"] &&
    detailDict[@"Driver"] == dict[@"Driver"] &&
    detailDict[@"Name"] == dict[@"Name"] &&
    detailDict[@"Notes"] == dict[@"Notes"] &&
    detailDict[@"Latitude"] == dict[@"Latitude"] &&
    detailDict[@"Longitude"] == dict[@"Longitude"] &&
    detailDict[@"Street"] == dict[@"Street"] &&
    detailDict[@"City"] == dict[@"City"] &&
    detailDict[@"Total Quantity to Deliver"] == dict[@"Total Quantity to Deliver"] &&
    detailDict[@"Category"] == dict[@"Category"];
}

- (void)loadPins {
    NSLog(@"Running LOADPINS method");
    // Deletes all prior pins
    [self removeAllPins:nil];
    
    // Figure out the closest pin to the user
    //    id<MKAnnotation> defaultPin = nil;
    double closestDistance = DBL_MAX;   // set distance to furthest so first result is less than this
    
    for( NSDictionary* d in self.pinsArray ){
        
        //      NSLog(@"[map] adding pin with data (%@ type): %@", NSStringFromClass([d class]), d);
        
        NSString *aLatitudeString = [d objectForKey:@"Latitude"];
        NSString *aLongitudeString = [d objectForKey:@"Longitude"];
        double aLatitude = [aLatitudeString doubleValue];
        double aLongitude = [aLongitudeString doubleValue];
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(aLatitude, aLongitude);
        BOOL hasShop = NO;  // [[d objectForKey:@"hasShop"] boolValue];
        
        //        NSString *aName = [d objectForKey:@"name"];
        //        NSString *aDescription = [d objectForKey:@"description"];
        //        BOOL hasShop = [d objectForKey:@"hasShop"];
        
        //        MapItem *aNewPin = [[MapItem alloc] initWithCoordinates:coordinates placeName:aName description:aDescription];
        
        // Adds annotations to the mapAnnotations array depending upon hasShop Boolean
        if (!hasShop) {
            MapItem *aNewPin = [[MapItem alloc] initWithCoordinates:coordinates memberData:d];
            aNewPin.memberData = d; // set data about the member so it can be passed to annotations and disclosures
            [self.mapAnnotations addObject:aNewPin];
            //               NSLog(@"HAS SHOP %@", aNewPin);
        } else {
            NoShopAnnotation *aNewPin = [[NoShopAnnotation alloc] initWithCoordinates:coordinates memberData:d];
            aNewPin.memberData = d; // set data about the member so it can be passed to annotations and disclosures
            [self.mapAnnotations addObject:aNewPin];
            //               NSLog(@"NO SHOP %@", aNewPin);
        }
        
        // Get distance between this new pin and the stored reference location (the user location or a faked Santa Cruz lat/long if location is disabled)
        CLLocation* loc = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
        
        // Get the distance and store the closest annotation
        double dist = [self.referenceLocation distanceFromLocation:loc];
        if( dist > 0 && dist < closestDistance ){
            closestDistance = dist;
            //            defaultPin = aNewPin;
        }
    }
    // If defaultPin is set, select it when we view the map
    [self.mapView selectAnnotation:self.defaultPin animated:YES];
    
    // loads the pins into the view
    //    [self.mapView addAnnotations:self.mapAnnotations];
}

- (void)removeAllPins:(UIButton *)sender {
    //    NSLog(@"Removing %d annotations from mapAnnotation array", [self.mapAnnotations count]);
    [self.mapAnnotations removeAllObjects];
    
    //    NSLog(@"Removing %d annotations from mapView annotations", [self.mapView.annotations count]);
    [self.mapView removeAnnotations:self.mapView.annotations];
}
/*
 - (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
 [self zoomToFitMapAnnotations];
 
 // If defaultPin is set, select it when we view the map
 [self.mapView selectAnnotation:self.defaultPin animated:YES];
 }
 */
#pragma mark - MapView Annotation Methods

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    // Sends User to the DetailViewController
    id<MKAnnotation> sender = view.annotation;
    NSLog(@"Performing SEGUE to detail view for annotation view: %@", sender);
    [self performSegueWithIdentifier:@"showDetail" sender:sender];
    
}

// Configures the Annotation popup
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // in case it's the user location, we already have an annotation, so just return ni
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    MapItem *currentItem;
    if ([annotation isKindOfClass:[MapItem class]]) {
        currentItem = (MapItem*)annotation;
        
    }
    //    NSLog(@"The annotation is %@", annotation);
    // try to dequeue an existing pin view first
    static NSString *BridgeAnnotationIdentifier = @"bridgeAnnotationIdentifier";
    
    //    MKPinAnnotationView *pinView =
    //    (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:BridgeAnnotationIdentifier];
    
    MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                          initWithAnnotation:annotation
                                          reuseIdentifier:BridgeAnnotationIdentifier];
    
    
    // Make the pin heads matches colors specified on the List & the GPSVisulaizer map
    
    if ([currentItem.pinColor isEqualToString:@"Red"] || [currentItem.pinColor isEqualToString:@"red"]) {
        customPinView.pinTintColor = UIColor.redColor;
    } else if ([currentItem.pinColor isEqualToString:@"Blue"] || [currentItem.pinColor isEqualToString:@"blue"]) {
        customPinView.pinTintColor = UIColor.blueColor;
    } else if ([currentItem.pinColor isEqualToString:@"Green"] || [currentItem.pinColor isEqualToString:@"green"]) {
        customPinView.pinTintColor = UIColor.greenColor;
    } else if ([currentItem.pinColor isEqualToString:@"Gray"] || [currentItem.pinColor isEqualToString:@"gray"]) {
        customPinView.pinTintColor = UIColor.grayColor;
    } else if ([currentItem.pinColor isEqualToString:@"Orange"] || [currentItem.pinColor isEqualToString:@"orange"]) {
        customPinView.pinTintColor = UIColor.orangeColor;
    } else if ([currentItem.pinColor isEqualToString:@"Purple"] || [currentItem.pinColor isEqualToString:@"purple"]) {
        customPinView.pinTintColor = UIColor.purpleColor;
    } else if ([currentItem.pinColor isEqualToString:@"Cyan"] || [currentItem.pinColor isEqualToString:@"cyan"]) {
        customPinView.pinTintColor = UIColor.cyanColor;
    } else if ([currentItem.pinColor isEqualToString:@"Yellow"] || [currentItem.pinColor isEqualToString:@"yellow"]) {
        customPinView.pinTintColor = UIColor.yellowColor;
    } else if ([currentItem.pinColor isEqualToString:@"Black"] || [currentItem.pinColor isEqualToString:@"black"]) {
        customPinView.pinTintColor = UIColor.blackColor;
    } else if ([currentItem.pinColor isEqualToString:@"Magenta"] || [currentItem.pinColor isEqualToString:@"magenta"]) {
        customPinView.pinTintColor = UIColor.magentaColor;
    } else if ([currentItem.pinColor isEqualToString:@"White"] || [currentItem.pinColor isEqualToString:@"white"]) {
        customPinView.pinTintColor = UIColor.whiteColor;
    }
    
    customPinView.canShowCallout = YES;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    //            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    customPinView.rightCalloutAccessoryView = rightButton;
    
    return customPinView;
}

@end