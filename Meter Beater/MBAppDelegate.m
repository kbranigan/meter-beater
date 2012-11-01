//
//  AppDelegate.m
//  mb
//
//  Created by Kevin Branigan on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBAppDelegate.h"

//#import <HockeySDK/HockeySDK.h>

//static NSString * const MBHockeyBetaIdentifierKey = @"MBHockeyBetaIdentifierKey";
//static NSString * const MBHockeyLiveIdentifierKey = @"MBHockeyLiveIdentifierKey";

//@interface MBAppDelegate () <BITCrashManagerDelegate, BITHockeyManagerDelegate, BITUpdateManagerDelegate>

//@end

@implementation MBAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    //NSString *betaIdentifier = [infoDictionary objectForKey:MBHockeyBetaIdentifierKey];
    //NSString *liveIdentifier = [infoDictionary objectForKey:MBHockeyLiveIdentifierKey];
    
    //[[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:betaIdentifier liveIdentifier:liveIdentifier delegate:self];
  
    //[[BITHockeyManager sharedHockeyManager] startManager];
    
    return YES;
}

#pragma mark - BITUpdateManagerDelegate conformance

/*- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager
{
#ifndef RELEASE_BUILD
    UIDevice *device = [UIDevice currentDevice];
    
    if([device respondsToSelector:@selector(uniqueIdentifier)])
        return [device performSelector:@selector(uniqueIdentifier)];
#endif
    
    return nil;
}*/

@end
