//
//  ViewController.m
//  mb
//
//  Created by Kevin Branigan on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "MeterBeater.h"
#import "StreetSideView.h"

@interface UIView (asdf)
- (NSString *)recursiveDescription;
@end

@implementation ViewController

@synthesize _navBar;
@synthesize _refreshBarButton;
@synthesize _scrollView;
@synthesize _meterBeater;
@synthesize _index;
@synthesize _streetSideViews;
@synthesize _activityIndicator;
@synthesize _locationManager;
@synthesize _location;

UIView * buttonSubViewInButton = NULL;
UIView * buttonSubViewInNavBar = NULL;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _index = 0;
  
  if (CLLocationManager.locationServicesEnabled)
  {
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [_locationManager startUpdatingLocation];
    
    _streetSideViews = [[NSMutableArray alloc] init];
    _meterBeater = [[MeterBeater alloc] initWithDelegate:self];
    [self setNavigationText:@"locating .."];
    [self setNavigationColor:NULL];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  }
  else
  {
    NSLog(@"location services turned off");
    [self setNavigationText:@"location services turned off"];
    [self setNavigationColor:NULL];
  }
}

- (void)doneRefreshing
{
  [buttonSubViewInNavBar addSubview:buttonSubViewInButton];
  [_activityIndicator stopAnimating];
  [_activityIndicator setHidden:YES];
}

- (IBAction)refreshRequested:(id)sender
{
  if (buttonSubViewInButton == NULL || buttonSubViewInNavBar == NULL)
  {
    for (UIView * subViewInNavBar in _navBar.subviews)
    {
      NSString * string = NSStringFromClass([subViewInNavBar class]);
      if ([[string substringToIndex:[string length] / 2] compare:@"UINavigat" options:NSCaseInsensitiveSearch] == NSOrderedSame &&
          [[string substringFromIndex:[string length] / 2] compare:@"ionButton" options:NSCaseInsensitiveSearch] == NSOrderedSame)
      {
        if ([subViewInNavBar isKindOfClass:[UIView class]] == YES)
        {
          for (UIView * subViewInButton in subViewInNavBar.subviews) {
            if ([subViewInButton isKindOfClass:[UIImageView class]] == YES && 
                subViewInButton.frame.origin.x != 0.0f &&
                subViewInButton.frame.origin.y != 0.0f)
            {
              buttonSubViewInButton = subViewInButton;
              buttonSubViewInNavBar = subViewInNavBar;
              
              [buttonSubViewInButton removeFromSuperview];
              
              CGRect aivFrame = _activityIndicator.frame;
              aivFrame.origin.x = (CGRectGetWidth(subViewInNavBar.frame) / 2.0) - (CGRectGetWidth(_activityIndicator.frame) / 2.0);
              aivFrame.origin.y = (CGRectGetHeight(subViewInNavBar.frame) / 2.0) - (CGRectGetHeight(_activityIndicator.frame) / 2.0);
              _activityIndicator.frame = aivFrame;
              
              [_activityIndicator setHidden:NO];
              [_activityIndicator startAnimating];
              [subViewInNavBar addSubview:_activityIndicator];
             
              if (_location)
                [_meterBeater requestUpdateAtLat:_location.coordinate.latitude andLng:_location.coordinate.longitude];
            }
          }
        }
      }
    }
  }
  else
  {
    if ([[buttonSubViewInNavBar subviews] indexOfObject:buttonSubViewInButton] == NSNotFound)
    {
      [self doneRefreshing];
    }
    else
    {
      [buttonSubViewInButton removeFromSuperview];
      [_activityIndicator startAnimating];
      [_activityIndicator setHidden:NO];
      if (_location)
        [_meterBeater requestUpdateAtLat:_location.coordinate.latitude andLng:_location.coordinate.longitude];
    }
  }
}

- (void)setNavigationText:(NSString*)text
{
  [_navBar popNavigationItemAnimated:NO];
  
  UINavigationItem * navigationItem = [[UINavigationItem alloc] initWithTitle:text];
  [navigationItem setRightBarButtonItem:_refreshBarButton];
  [_refreshBarButton setAction:@selector(refreshRequested:)];
  [_navBar pushNavigationItem:navigationItem animated:NO];
}

- (void)setNavigationColor:(UIColor*)color
{
  [_navBar setTintColor:color];
}

- (void)updateNavigationTitle
{
  if (_scrollView == nil || _scrollView.contentSize.width == 0) return;
  
  _index = (int)round((_scrollView.contentSize.width / _scrollView.frame.size.width) * _scrollView.contentOffset.x / (float)(_scrollView.contentSize.width));
  
  if (_index < [_streetSideViews count])
  {
    StreetSideView * ssv = [_streetSideViews objectAtIndex:_index];
    
    //[self setNavigationText:[NSString stringWithFormat:@"%@, %@ side", [ssv.streetname capitalizedString], ssv.streetside]];
    [self setNavigationText:[NSString stringWithFormat:@"%@, %@ side", [ssv.streetname capitalizedString], [ssv.data objectForKey:@"side"]]];
    [self setNavigationColor:ssv.color];
  }
  else
  {
    [self setNavigationText:@"loading"];
    [self setNavigationColor:NULL];
  }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  // alert something
  //[self setNavigationText:@"location services failed"];
  
  //NSLog(@"locationManager failed");
  [self doneRefreshing];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
  if (newLocation.horizontalAccuracy < 100)
  {
    if (_location == NULL)
      [self setNavigationText:@"ready!"];
    
    [_refreshBarButton setEnabled:YES];
    _location = newLocation;
  }
  
  //NSLog(@"update at %f %f (%f %f)", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.horizontalAccuracy, newLocation.verticalAccuracy);
  //[_meterBeater requestUpdateAtLat:newLocation.coordinate.latitude andLng:newLocation.coordinate.longitude];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  [self updateNavigationTitle];
}

- (void)meterBeaterDidUpdate
{
  [self doneRefreshing];
  
  NSString * oldstreetname = NULL;
  NSString * oldstreetside = NULL;
  
  if (_index < [_streetSideViews count])
  {
    StreetSideView * oldssv = [_streetSideViews objectAtIndex:_index];
    oldstreetname = oldssv.streetname;
    oldstreetside = oldssv.streetside;
  }
  _index = 0;
  
  for (id ssv in _streetSideViews)
  {
    [ssv removeFromSuperview];
  }
  
  [_streetSideViews removeAllObjects];
  int count = 0;
  for (NSString * street in [[_meterBeater.data objectForKey:@"streets"] allKeys])
  {
    for (NSString * side in [[_meterBeater.data objectForKey:@"streets"] objectForKey:street])
    {
      if ([side compare:@"odd"]!=0 && [side compare:@"even"]!=0) continue;
      
      StreetSideView * ssv = [[StreetSideView alloc] initWithFrame:CGRectMake(count*_scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
      ssv.streetname = street;
      ssv.streetside = side;
      ssv.viewController = self;
      
      [ssv setData:[[[_meterBeater.data objectForKey:@"streets"] objectForKey:street] objectForKey:side]];
      [_scrollView addSubview:ssv];
      [_streetSideViews addObject:ssv];
      
      if ([street compare:oldstreetname]==0 && [side compare:oldstreetside]==0)
      {
        _index = count;
      }
      count++;
    }
  }
  [_scrollView setContentSize:CGSizeMake(count*_scrollView.frame.size.width, _scrollView.frame.size.height)];
  [_scrollView setContentOffset:CGPointMake(_index*_scrollView.frame.size.width, 0)];
  [_scrollView setPagingEnabled:true];
  [_scrollView setDelegate:self];
  
  [self updateNavigationTitle];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
