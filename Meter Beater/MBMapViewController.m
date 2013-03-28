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
static const CGFloat        MBRegionLineWidth     =   3.0;
static const CGFloat        MBAddressLineWidth    =   3.0;
static const NSTimeInterval MBTimeBetweenRequests =   5.0;

static NSString * const MBMostRecentLatitude  = @"MBMostRecentLatitude";
static NSString * const MBMostRecentLongitude = @"MBMostRecentLongitude";

@interface MBMapViewController () <MKMapViewDelegate>

@property(nonatomic, weak) IBOutlet MKMapView          *mapView;
@property(nonatomic, weak) IBOutlet UISegmentedControl *paymentControl;
@property(nonatomic, copy) NSArray                     *paymentOptions;
@property(nonatomic, weak) IBOutlet UIBarButtonItem    *trackButtonItem;
@property(nonatomic, weak) IBOutlet UIBarButtonItem    *infoButtonItem;
@property(nonatomic, weak) IBOutlet UIBarButtonItem    *negativeSeparator;
@property(nonatomic, weak) IBOutlet UIButton           *infoButton;
@property(nonatomic, weak) IBOutlet UISegmentedControl *timeControl;
@property(nonatomic, copy) NSArray                     *timeRanges;
@property(nonatomic, weak) IBOutlet UIBarButtonItem    *untilButton;

- (IBAction)MB_didTapTrackButtonItem:(UIBarButtonItem *)sender;
- (IBAction)MB_didTapPaymentControl:(UISegmentedControl *)sender;
- (IBAction)MB_didTapTimeControl:(UISegmentedControl *)sender;

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
    MKPolygon           *regionOverlay;
    NSDate              *lastRequest;
    CGSize               mapSpan;
}

@synthesize mapView, paymentOptions, paymentControl, trackButtonItem, infoButtonItem, infoButton, timeControl, timeRanges, untilButton, negativeSeparator;

- (UIColor *)MB_regionStrokeColour
{
    return [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.20];
}

- (UIColor *)MB_regionFillColour
{
    return [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.05];
}

- (UIColor *)MB_colourForValue:(CGFloat)value
{
    return [UIColor colorWithHue:MAX(0.0, (1.0 - value) / 3.0) saturation:1.0 brightness:0.8 alpha:1.0];
}

- (IBAction)MB_didTapTrackButtonItem:(UIBarButtonItem *)sender
{
    [[self trackButtonItem] setStyle:UIBarButtonItemStyleDone];
  
    CLLocation *location = [[[self mapView] userLocation] location];
    
    if(location != nil)
    {
        forceRequest = YES;
        
        [[self mapView] setRegion:MKCoordinateRegionMakeWithDistance([location coordinate], mapSpan.width, mapSpan.height) animated:YES];
    }
}

- (IBAction)MB_didTapTimeControl:(UISegmentedControl *)sender
{
    [self MB_reloadMapView];
}

- (IBAction)MB_didTapPaymentControl:(UISegmentedControl *)sender
{
    [self MB_reloadMapView];
}

- (void)MB_reloadMapView
{
    NSArray *overlays = [cachedOverlays allValues];
    
    [[self mapView] removeOverlays:overlays];
    
    if(regionOverlay != nil)
        [[self mapView] removeOverlay:regionOverlay];
    
    [[self mapView] addOverlays:overlays];
    
    if(regionOverlay != nil)
        [[self mapView] addOverlay:regionOverlay];
}

- (void)setTimeRanges:(NSArray *)ranges
{
    if(![ranges isEqualToArray:timeRanges])
    {
        NSInteger  selectedIndex = [[self timeControl] selectedSegmentIndex];
        NSNumber  *selectedRange = selectedIndex >= 0 && selectedIndex < [timeRanges count] ? [timeRanges objectAtIndex:selectedIndex] : nil;
        
        timeRanges = [ranges copy];
        
        [[self timeControl] removeAllSegments];
        
        for(id range in timeRanges)
            [[self timeControl] insertSegmentWithTitle:[range description] atIndex:NSIntegerMax animated:NO];
        
        NSInteger index = [timeRanges indexOfObject:selectedRange];
        
        if(index == NSNotFound)
            index = selectedIndex;
        if(index >= [[self timeControl] numberOfSegments])
            index = [[self timeControl] numberOfSegments] - 1;
        if(index < 0)
            index = 0;
        
        [[self timeControl] setSelectedSegmentIndex:index];
        
        [self MB_reloadMapView];
    }
}

- (void)setPaymentOptions:(NSArray *)options
{
  if(![options isEqualToArray:paymentOptions])
  {
    NSInteger  selectedIndex = [[self paymentControl] selectedSegmentIndex];
    NSNumber  *selectedRange = selectedIndex >= 0 && selectedIndex < [paymentOptions count] ? [paymentOptions objectAtIndex:selectedIndex] : nil;
    
    paymentOptions = [options copy];
    
    [[self paymentControl] removeAllSegments];
    
    for(id option in paymentOptions)
      [[self paymentControl] insertSegmentWithTitle:[option description] atIndex:NSIntegerMax animated:NO];
    
    NSInteger index = [paymentOptions indexOfObject:selectedRange];
    
    if(index == NSNotFound)
      index = selectedIndex;
    if(index >= [[self timeControl] numberOfSegments])
      index = [[self timeControl] numberOfSegments] - 1;
    if(index < 0)
      index = 0;
    
    [[self paymentControl] setSelectedSegmentIndex:index];
    
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
    
    [[self untilButton] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont fontWithName:@"Helvetica-Bold" size:12.0], UITextAttributeFont, nil]
                                      forState:UIControlStateNormal];
    [[self untilButton] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], UITextAttributeTextColor, nil]
                                      forState:UIControlStateDisabled];
    [[self untilButton] setTitle:@"until:"];
    [[self negativeSeparator] setWidth:-10];
  
    [self setPaymentOptions:[NSArray arrayWithObjects:@"Free", @"Meter", @"Lots", nil]];
    [self setTimeRanges:[NSArray arrayWithObjects:@"", @"", @"", nil]];
    
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
    
    mapSpan = CGSizeMake(MBMapSpan, MBMapSpan);
    
    if(latitude != nil && longitude != nil)
        [[self mapView] setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]), mapSpan.width, mapSpan.height) animated:YES];
    
    ignoreRegionChanges = YES;
    
    [[self trackButtonItem] setStyle:UIBarButtonItemStyleDone];
    
    [[self infoButtonItem] setCustomView:infoButton];
    
    [[self mapView] setShowsUserLocation:YES];
}

#pragma mark - MKMapViewDelegate conformance

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if(!ignoreRegionChanges && !animated)
        [[self trackButtonItem] setStyle:UIBarButtonItemStyleBordered];
}

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
    if(!forceRequest && (ignoreRegionChanges || (animated && lastRequest != nil && -[lastRequest timeIntervalSinceNow] < MBTimeBetweenRequests))) return;
    
    forceRequest = NO;
    lastRequest  = [NSDate date];
    
    CLLocationCoordinate2D coordinate = [aMapView centerCoordinate];
    
    [MBAPIAccess cancelPendingRequests];
  
    NSString * payment = [paymentOptions objectAtIndex:[[self paymentControl] selectedSegmentIndex]];
    [MBAPIAccess requestObjectWithURL:[MBAPIAccess requestURLWithPayment:payment latitude:coordinate.latitude longitude:coordinate.longitude] completionBlock:
     ^(NSDictionary *object, NSError *error)
     {
         MBResponse *response = [MBResponse responseWithDictionary:object];
         
         [self setTimeRanges:[response ranges]];
         [self setPaymentOptions:[response paymentOptions]];
         
         NSMutableArray *removedIdentifiers = [NSMutableArray arrayWithCapacity:[cachedAddresses count]];
         
         CGRect region = [response region];
         
         MKMapPoint corners[4] =
         {
             MKMapPointForCoordinate(CLLocationCoordinate2DMake(CGRectGetMinX(region), CGRectGetMinY(region))),
             MKMapPointForCoordinate(CLLocationCoordinate2DMake(CGRectGetMaxX(region), CGRectGetMinY(region))),
             MKMapPointForCoordinate(CLLocationCoordinate2DMake(CGRectGetMaxX(region), CGRectGetMaxY(region))),
             MKMapPointForCoordinate(CLLocationCoordinate2DMake(CGRectGetMinX(region), CGRectGetMaxY(region)))
         };
         
         mapSpan.width  = MKMetersBetweenMapPoints(corners[0], corners[1]) / 2.0;
         mapSpan.height = MKMetersBetweenMapPoints(corners[1], corners[2]) / 2.0;
         
         MKMapRect mapRegion = { corners[0], MKMapSizeMake(corners[2].x - corners[0].x, corners[2].y - corners[0].y) };
         
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
         
         if(regionOverlay != nil)
             [aMapView removeOverlay:regionOverlay];
         
         regionOverlay = [MKPolygon polygonWithPoints:corners count:sizeof(corners) / sizeof(corners[0])];
         
         [aMapView addOverlay:regionOverlay];
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
    
    if([[self trackButtonItem] style] == UIBarButtonItemStyleDone)
    {
        ignoreRegionChanges = NO;
        
        [aMapView setRegion:MKCoordinateRegionMakeWithDistance(coordinate, mapSpan.width, mapSpan.height) animated:YES];
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
    if([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonView *view = [[MKPolygonView alloc] initWithOverlay:overlay];
        
        [view setLineWidth:[[UIScreen mainScreen] scale] * MBRegionLineWidth];
        [view setStrokeColor:[self MB_regionStrokeColour]];
        [view setFillColor:[self MB_regionFillColour]];
        
        return view;
    }
    else
    {
        MKPolylineView *view = [[MKPolylineView alloc] initWithOverlay:overlay];
        
        [view setLineWidth:[[UIScreen mainScreen] scale] * MBAddressLineWidth];
        [view setStrokeColor:[self MB_colourForValue:[[[[overlay address] values] objectAtIndex:[[self timeControl] selectedSegmentIndex]] floatValue]]];
        
        return view;
    }
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
