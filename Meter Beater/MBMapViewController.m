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

static const CGFloat        MBMapSpan             = 250.0;
static const CGFloat        MBLineWidth           =   3.0;
static const NSTimeInterval MBTimeBetweenRequests =   5.0;

static NSString * const MBMostRecentLatitude  = @"MBMostRecentLatitude";
static NSString * const MBMostRecentLongitude = @"MBMostRecentLongitude";

@interface MBMapViewController () <MKMapViewDelegate>

@property(nonatomic, weak) IBOutlet MKMapView          *mapView;
@property(nonatomic, weak) IBOutlet UIBarButtonItem    *trackButton;
@property(nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic, copy) NSArray                     *timeRanges;

- (IBAction)MB_didTapTrackButton:(UIBarButtonItem *)sender;

@end

@interface MBPolyline : MKMultiPoint <MKOverlay>

+ (id)polylineWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count;
+ (id)polylineWithPoints:(MKMapPoint *)points count:(NSUInteger)count;

@property(nonatomic) MBAddress *address;

@end

@implementation MBMapViewController
{
    BOOL                 forceRequest;
    BOOL                 ignoreRegionChanges;
    NSMutableDictionary *cachedAddresses;
    NSMutableDictionary *cachedOverlays;
    NSDate              *lastRequest;
}

@synthesize mapView, trackButton, segmentedControl, timeRanges;

- (UIColor *)MB_colourForValue:(CGFloat)value
{
    return [UIColor colorWithHue:value / 3.0 saturation:1.0 brightness:1.0 alpha:1.0];
}

- (IBAction)MB_didTapTrackButton:(UIBarButtonItem *)sender
{
    [[self trackButton] setStyle:UIBarButtonItemStyleDone];
    
    CLLocation *location = [[[self mapView] userLocation] location];
    
    if(location != nil)
    {
        forceRequest = YES;
        
        [[self mapView] setRegion:MKCoordinateRegionMakeWithDistance([location coordinate], MBMapSpan, MBMapSpan) animated:YES];
    }
}

- (IBAction)MB_didTapSegmentedControl:(UISegmentedControl *)sender
{
    [self MB_reloadMapView];
}

- (void)MB_reloadMapView
{
    NSArray *overlays = [cachedOverlays allValues];
    
    [[self mapView] removeOverlays:overlays];
    [[self mapView] addOverlays:overlays];
}

- (void)setTimeRanges:(NSArray *)ranges
{
    if(![ranges isEqualToArray:timeRanges])
    {
        NSInteger  selectedIndex = [[self segmentedControl] selectedSegmentIndex];
        NSNumber  *selectedRange = selectedIndex >= 0 && selectedIndex < [timeRanges count] ? [timeRanges objectAtIndex:selectedIndex] : nil;
        
        timeRanges = [ranges copy];
        
        [[self segmentedControl] removeAllSegments];
        
        for(id range in timeRanges)
            [[self segmentedControl] insertSegmentWithTitle:[range description] atIndex:NSIntegerMax animated:NO];
        
        NSInteger index = [timeRanges indexOfObject:selectedRange];
        
        if(index == NSNotFound)
            index = selectedIndex;
        if(index >= [[self segmentedControl] numberOfSegments])
            index = [[self segmentedControl] numberOfSegments] - 1;
        if(index < 0)
            index = 0;
        
        [[self segmentedControl] setSelectedSegmentIndex:index];
        
        [self MB_reloadMapView];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTimeRanges:[NSArray arrayWithObjects:@"1 hour", @"3 hours", @"6 hours", nil]];
    
    cachedAddresses = [NSMutableDictionary dictionary];
    cachedOverlays  = [NSMutableDictionary dictionary];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithFloat: 43.648100], MBMostRecentLatitude,
      [NSNumber numberWithFloat:-79.404200], MBMostRecentLongitude,
      nil]];
    
    NSNumber *latitude  = [defaults objectForKey:MBMostRecentLatitude];
    NSNumber *longitude = [defaults objectForKey:MBMostRecentLongitude];
    
    if(latitude != nil && longitude != nil)
        [[self mapView] setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]), MBMapSpan, MBMapSpan) animated:YES];
    
    ignoreRegionChanges = YES;
    
    [[self trackButton] setStyle:UIBarButtonItemStyleDone];
    
    [[self mapView] setShowsUserLocation:YES];
}

#pragma mark - MKMapViewDelegate conformance

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if(!ignoreRegionChanges && !animated)
        [[self trackButton] setStyle:UIBarButtonItemStyleBordered];
}

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
    if(!forceRequest && (ignoreRegionChanges || (animated && lastRequest != nil && -[lastRequest timeIntervalSinceNow] < MBTimeBetweenRequests))) return;
    
    forceRequest = NO;
    lastRequest  = [NSDate date];
    
    CLLocationCoordinate2D coordinate = [aMapView centerCoordinate];
    
    [MBAPIAccess cancelPendingRequests];
    
    [MBAPIAccess requestObjectWithURL:[MBAPIAccess requestURLWithLatitude:coordinate.latitude longitude:coordinate.longitude] completionBlock:
     ^(NSDictionary *object, NSError *error)
     {
         MBResponse *response = [MBResponse responseWithDictionary:object];
         
         [self setTimeRanges:[response ranges]];
         
         NSMutableArray *removedIdentifiers = [NSMutableArray arrayWithCapacity:[cachedAddresses count]];
         
         CGRect region = [response region];
         
         MKMapPoint minPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(CGRectGetMinX(region), CGRectGetMinY(region)));
         MKMapPoint maxPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(CGRectGetMaxX(region), CGRectGetMaxY(region)));
         
         MKMapRect mapRegion = { minPoint, MKMapSizeMake(maxPoint.x - minPoint.x, maxPoint.y - minPoint.y) };
         
         for(NSString *identifier in cachedOverlays)
         {
             id<MKOverlay> cachedOverlay = [cachedOverlays objectForKey:identifier];
             
             if(![cachedOverlay intersectsMapRect:mapRegion])
                 [removedIdentifiers addObject:identifier];
         }
         
         [aMapView removeOverlays:[cachedOverlays objectsForKeys:removedIdentifiers notFoundMarker:[NSNull null]]];
         
         [cachedAddresses removeObjectsForKeys:removedIdentifiers];
         [cachedOverlays  removeObjectsForKeys:removedIdentifiers];
         
         for(MBAddress *address in [response addresses])
         {
             MBAddress *cachedAddress = [cachedAddresses objectForKey:[address identifier]];
             
             if(![[address values] isEqualToArray:[cachedAddress values]])
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
             
             [cachedAddresses setObject:address forKey:[address identifier]];
         }
     }];
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if([userLocation location] == nil)
        return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CLLocationCoordinate2D coordinate = [[userLocation location] coordinate];
    
    [defaults setFloat:coordinate.latitude  forKey:MBMostRecentLatitude];
    [defaults setFloat:coordinate.longitude forKey:MBMostRecentLongitude];
    
    if([[self trackButton] style] == UIBarButtonItemStyleDone)
    {
        ignoreRegionChanges = NO;
        
        [aMapView setRegion:MKCoordinateRegionMakeWithDistance(coordinate, MBMapSpan, MBMapSpan) animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    ignoreRegionChanges = NO;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"Couldn't detect current location." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    
    [alertView show];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(MBPolyline *)overlay
{
    MKPolylineView *view = [[MKPolylineView alloc] initWithOverlay:overlay];
    
    [view setLineWidth:[[UIScreen mainScreen] scale] * MBLineWidth];
    [view setStrokeColor:[self MB_colourForValue:[[[[overlay address] values] objectAtIndex:[[self segmentedControl] selectedSegmentIndex]] floatValue]]];
    
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
