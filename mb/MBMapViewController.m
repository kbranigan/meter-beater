//
//  MBMapViewController.m
//  mb
//
//  Created by William Hua on 2012-08-17.
//  Copyright (c) 2012 Refactory. All rights reserved.
//

#import "MBMapViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "MBAPIAccess.h"
#import "MBResponse.h"

static const CGFloat MBMapSpan = 250.0;

static NSString * const MBMostRecentLatitude  = @"MBMostRecentLatitude";
static NSString * const MBMostRecentLongitude = @"MBMostRecentLongitude";

@interface MBMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property(nonatomic, weak) IBOutlet MKMapView *mapView;

@property(nonatomic) CLLocationManager *locationManager;

@end

@implementation MBMapViewController

@synthesize mapView, locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *latitude  = [defaults objectForKey:MBMostRecentLatitude];
    NSNumber *longitude = [defaults objectForKey:MBMostRecentLongitude];
    
    if(latitude != nil && longitude != nil)
        [[self mapView] setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]), MBMapSpan, MBMapSpan)];
    
    if([CLLocationManager locationServicesEnabled])
    {
        locationManager = [[CLLocationManager alloc] init];
        
        [locationManager setDelegate:self];
        [locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate conformance

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CLLocationCoordinate2D coordinate = [newLocation coordinate];
    
    [defaults setFloat:coordinate.latitude  forKey:MBMostRecentLatitude];
    [defaults setFloat:coordinate.longitude forKey:MBMostRecentLongitude];
    
    [MBAPIAccess requestObjectWithURL:[MBAPIAccess requestURLWithLatitude:coordinate.latitude longitude:coordinate.longitude] completionBlock:
     ^(NSDictionary *object, NSError *error)
     {
         MBResponse *response = [MBResponse responseWithDictionary:object];
         
         [mapView removeOverlays:[mapView overlays]];
         
         for(MBAddress *address in [response addresses])
         {
             CLLocationCoordinate2D *vertices = malloc([[address vertices] count] * sizeof(CLLocationCoordinate2D));
             
             for(NSUInteger index = 0; index < [[address vertices] count]; index++)
             {
                 CGPoint point = [[[address vertices] objectAtIndex:index] CGPointValue];
                 
                 vertices[index] = CLLocationCoordinate2DMake(point.x, point.y);
             }
             
             MKPolyline *polyline = [MKPolyline polylineWithCoordinates:vertices count:[[address vertices] count]];
             
             [mapView addOverlay:polyline];
         }
     }];
}

#pragma mark - MKMapViewDelegate conformance

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineView *view = [[MKPolylineView alloc] initWithOverlay:overlay];
    
    [view setStrokeColor:[UIColor redColor]];
    [view setLineWidth:3.0];
    
    return view;
}

@end
