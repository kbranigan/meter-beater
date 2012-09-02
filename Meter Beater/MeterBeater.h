//
//  MeterBeater.h
//  meterbeater
//
//  Created by Kevin Branigan on 12-05-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewController;

@interface MeterBeater : NSObject

@property (nonatomic, strong) NSURLConnection * connection;
@property (nonatomic, strong) NSMutableData * receivedData;
@property (nonatomic, strong) ViewController * viewController;
@property (nonatomic, strong) NSDictionary * data;
@property (nonatomic, strong) NSMutableDictionary * infractions;

- (id)initWithDelegate:(ViewController*)vc;
- (void)requestUpdateAtLat:(float)lat andLng:(float)lng;

@end
