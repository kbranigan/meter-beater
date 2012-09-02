//
//  ViewController.h
//  mb
//
//  Created by Kevin Branigan on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class MeterBeater;

@interface ViewController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UINavigationBar * _navBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * _refreshBarButton;
@property (nonatomic, strong) IBOutlet UIScrollView * _scrollView;
@property (nonatomic, strong) MeterBeater * _meterBeater;

@property (nonatomic, strong) UIActivityIndicatorView * _activityIndicator;

@property (nonatomic) NSInteger _index;

@property (nonatomic, strong) NSMutableArray * _streetSideViews;

@property (nonatomic, retain) CLLocationManager * _locationManager;
@property (nonatomic, retain) CLLocation * _location;

- (IBAction)refreshRequested:(id)sender;
- (void)setNavigationText:(NSString*)text;
- (void)setNavigationColor:(UIColor*)color;

- (void)meterBeaterDidUpdate;

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;


@end
