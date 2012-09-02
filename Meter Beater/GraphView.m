//
//  GraphView.m
//  meterbeater
//
//  Created by Kevin Branigan on 12-05-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "StreetSideView.h"
#import "MeterBeater.h"

@implementation GraphView

@synthesize ssv;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.opaque = NO;
    // Initialization code
  }
  
  return self;
}

- (void)drawRect:(CGRect)rect
{
  [[UIColor brownColor] set];
  
  if (ssv == nil) return;
  
  CGContextRef currentContext = UIGraphicsGetCurrentContext();
  
  CGContextSetLineWidth(currentContext, 1.5f);
  
  //NSDictionary * street_data = [[ssv.data objectForKey:@"streets"] objectForKey:ssv.streetname];
  NSArray * prohibited_tickets_hourly = [ssv.data objectForKey:@"prohibited_tickets_hourly"];
  
  int max = 0;
  for (int i = 0 ; i < 48 ; i++)
  {
    int val = 0;
    for (int wday = 0 ; wday < 7 ; wday++)
    {
      val += [[[prohibited_tickets_hourly objectAtIndex:wday] objectAtIndex:i] intValue];
    }
    if (val > max) max = val;
  }
  
  
  CGContextMoveToPoint(currentContext, 0.0f, 0.0f);
  for (int i = 0 ; i < 48 ; i++)
  {
    int val = 0;
    for (int wday = 0 ; wday < 7 ; wday++)
    {
      val += [[[prohibited_tickets_hourly objectAtIndex:wday] objectAtIndex:i] intValue];
    }
    //for (NSArray * pth_wday in prohibited_tickets_hourly)
    //{
      //for (NSNumber * count in pth_wday) //float f = 0 ; f < self.bounds.size.width ; f++)
      
      //for (int i = 0 ; i < [pth_wday count] ; i++)
      {
        float x = (float)i / 48.0 * (self.bounds.size.width-5) + 5;
        float y = self.bounds.size.height - (val / (float)max) * (self.bounds.size.height - 5) - 4;
        
        if (i == 0)
          CGContextMoveToPoint(currentContext, x, y);
        else
          CGContextAddLineToPoint(currentContext, x, y);
      }
    //}
  }
  
  //for (NS * numeric_side in [street_data objectForKey:streetside])
  {
    //NSLog(@"numeric_side %@", numeric_side);
    //if ([numeric_side compare:@"odd"]==0 || [numeric_side compare:@"even"]==0)
    //  [_masterView addStreet:street withSide:numeric_side];
  }
  
  CGContextStrokePath(currentContext);
}


@end
