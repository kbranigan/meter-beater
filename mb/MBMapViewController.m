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

@interface MBMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property(nonatomic, weak) IBOutlet MKMapView *mapView;

@property(nonatomic) CLLocationManager *locationManager;

@end

@implementation MBMapViewController

@synthesize mapView, locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self mapView] setShowsUserLocation:YES];
    [[self mapView] setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(43.638778, -79.413366), 250.0, 250.0)];
    
    CLLocationCoordinate2D circle;
    CLLocationCoordinate2D polyline[3];
    CLLocationCoordinate2D polygon[4];
    
    circle = CLLocationCoordinate2DMake(43.638678, -79.413266);
    
    polyline[0] = CLLocationCoordinate2DMake(43.637778, -79.414366);
    polyline[1] = CLLocationCoordinate2DMake(43.638078, -79.413766);
    polyline[2] = CLLocationCoordinate2DMake(43.638778, -79.413366);
    
    polygon[0] = CLLocationCoordinate2DMake(43.638778, -79.415366);
    polygon[1] = CLLocationCoordinate2DMake(43.638778, -79.414366);
    polygon[2] = CLLocationCoordinate2DMake(43.637778, -79.414366);
    polygon[3] = CLLocationCoordinate2DMake(43.637778, -79.415366);
    
    [[self mapView] addOverlay:[MKCircle circleWithCenterCoordinate:circle radius:10.0]];
    
    [[self mapView] addOverlay:[MKPolyline polylineWithCoordinates:polyline count:sizeof(polyline) / sizeof(polyline[0])]];
    
    [[self mapView] addOverlay:[MKPolygon polygonWithCoordinates:polygon count:sizeof(polygon) / sizeof(polygon[0])]];
    
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
    [[self mapView] setCenterCoordinate:[newLocation coordinate]];
}

#pragma mark - MKMapViewDelegate conformance

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        
        return circleView;
    }
    else if([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithOverlay:overlay];
        
        [polylineView setStrokeColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:0.4]];
        [polylineView setLineWidth:10.0];
        
        return polylineView;
    }
    else if([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithOverlay:overlay];
        
        [polygonView setFillColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.2]];
        [polygonView setStrokeColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.4]];
        [polygonView setLineWidth:2.0];
        
        return polygonView;
    }
    
    return nil;
}

@end
