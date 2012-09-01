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

@interface MBMapViewController () <MKMapViewDelegate>

@property(nonatomic, weak) IBOutlet MKMapView *mapView;
@property(nonatomic, weak) IBOutlet UIToolbar *toolbar;

- (IBAction)MB_didTapTrackButton:(UIBarButtonItem *)sender;

@end

@interface MBPolyline : MKMultiPoint <MKOverlay>

+ (id)polylineWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count;
+ (id)polylineWithPoints:(MKMapPoint *)points count:(NSUInteger)count;

@property(nonatomic) MBAddress *address;

@end

@implementation MBMapViewController
{
    BOOL                 trackingEnabled;
    NSMutableDictionary *cachedOverlays;
}

@synthesize mapView, toolbar;

- (UIColor *)MB_colourForValue:(CGFloat)value
{
    return [UIColor colorWithHue:value / 3.0 saturation:1.0 brightness:1.0 alpha:0.5];
}

- (void)MB_didTapTrackButton:(UIBarButtonItem *)sender
{
    trackingEnabled = YES;
    
    [[self mapView] setCenterCoordinate:[[[[self mapView] userLocation] location] coordinate] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cachedOverlays = [NSMutableDictionary dictionary];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *latitude  = [defaults objectForKey:MBMostRecentLatitude];
    NSNumber *longitude = [defaults objectForKey:MBMostRecentLongitude];
    
    if(latitude != nil && longitude != nil)
        [[self mapView] setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]), MBMapSpan, MBMapSpan) animated:YES];
    
    trackingEnabled = YES;
    
    [[self mapView] setShowsUserLocation:YES];
}

#pragma mark - MKMapViewDelegate conformance

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    trackingEnabled = trackingEnabled && animated;
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CLLocationCoordinate2D coordinate = [[userLocation location] coordinate];
    
    [defaults setFloat:coordinate.latitude  forKey:MBMostRecentLatitude];
    [defaults setFloat:coordinate.longitude forKey:MBMostRecentLongitude];
    
    if(trackingEnabled)
        [[self mapView] setCenterCoordinate:coordinate animated:YES];
    
    [MBAPIAccess requestObjectWithURL:[MBAPIAccess requestURLWithLatitude:coordinate.latitude longitude:coordinate.longitude] completionBlock:
     ^(NSDictionary *object, NSError *error)
     {
         MBResponse *response = [MBResponse responseWithDictionary:object];
         
         for(MBAddress *address in [response addresses])
         {
             NSUInteger count = [[address vertices] count];
             
             CLLocationCoordinate2D *vertices = malloc(count * sizeof(CLLocationCoordinate2D));
             
             for(NSUInteger index = 0; index < count; index++)
             {
                 CGPoint point = [[[address vertices] objectAtIndex:index] CGPointValue];
                 
                 vertices[index] = CLLocationCoordinate2DMake(point.x, point.y);
             }
             
             MBPolyline *addedOverlay = [MBPolyline polylineWithCoordinates:vertices count:count];
             
             [addedOverlay setAddress:address];
             [aMapView addOverlay:addedOverlay];
             
             id<MKOverlay> cachedOverlay = [cachedOverlays objectForKey:[address identifier]];
             
             if(cachedOverlay != nil)
                 [aMapView removeOverlay:cachedOverlay];
             
             [cachedOverlays setObject:addedOverlay forKey:[address identifier]];
         }
     }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"Couldn't detect current location." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    
    [alertView show];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(MBPolyline *)overlay
{
    MKPolylineView *view = [[MKPolylineView alloc] initWithOverlay:overlay];
    
    [view setLineWidth:3.0];
    [view setStrokeColor:[self MB_colourForValue:[[[[overlay address] values] objectAtIndex:0] floatValue]]];
    
    return view;
}

@end

@implementation MBPolyline
{
    MKPolyline *polyline;
}

@synthesize address;

+ (id)polylineWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    return [[self alloc] initWithCoordinates:coords count:count];
}

+ (id)polylineWithPoints:(MKMapPoint *)points count:(NSUInteger)count
{
    return [[self alloc] initWithPoints:points count:count];
}

- (id)initWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    if((self = [super init]))
        polyline = [MKPolyline polylineWithCoordinates:coords count:count];
    
    return self;
}

- (id)initWithPoints:(MKMapPoint *)points count:(NSUInteger)count
{
    if((self = [super init]))
        polyline = [MKPolyline polylineWithPoints:points count:count];
    
    return self;
}

#pragma mark - MKShape redefinition

- (NSString *)title
{
    return [polyline title];
}

- (void)setTitle:(NSString *)title
{
    [polyline setTitle:title];
}

- (NSString *)subtitle
{
    return [polyline subtitle];
}

- (void)setSubtitle:(NSString *)subtitle
{
    [polyline setSubtitle:subtitle];
}

#pragma mark - MKMultiPoint redefinition

- (NSUInteger)pointCount
{
    return [polyline pointCount];
}

- (MKMapPoint *)points
{
    return [polyline points];
}

- (void)getCoordinates:(CLLocationCoordinate2D *)coords range:(NSRange)range
{
    [polyline getCoordinates:coords range:range];
}

#pragma mark - MKOverlay conformance

- (CLLocationCoordinate2D)coordinate
{
    return [polyline coordinate];
}

- (MKMapRect)boundingMapRect
{
    return [polyline boundingMapRect];
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect
{
    return [polyline intersectsMapRect:mapRect];
}

@end
