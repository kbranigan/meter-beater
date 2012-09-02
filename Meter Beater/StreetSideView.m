//
//  StreetSideView.m
//  mb
//
//  Created by Kevin Branigan on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StreetSideView.h"
#import "ViewController.h"
#import "MeterBeater.h"
#import "GraphView.h"
#import "StreetSideAttributeCell.h"

#import <QuartzCore/QuartzCore.h>

@implementation StreetSideView

@synthesize streetname;
@synthesize streetside;
@synthesize data;
@synthesize viewController;
@synthesize tableView = _tableView;
@synthesize graphView = _graphView;
@synthesize cells;
@synthesize color = _color;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    cells = [[NSMutableArray alloc] init];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewController._scrollView.frame.size.width, viewController._scrollView.frame.size.height * 0.5) style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self addSubview:_tableView];
    
    _graphView = [[GraphView alloc] initWithFrame:CGRectMake(0, viewController._scrollView.frame.size.height * 0.5, viewController._scrollView.frame.size.width, viewController._scrollView.frame.size.height * 0.5)];
    _graphView.ssv = self;
    [self addSubview:_graphView];
  }
  return self;
}

- (void)layoutSubviews
{
  if (_tableView) [_tableView setFrame:CGRectMake(0, 
                                                  0, 
                                                  viewController._scrollView.frame.size.width, 
                                                  viewController._scrollView.frame.size.height * 0.75)];
  if (_graphView) [_graphView setFrame:CGRectMake(0, 
                                                  viewController._scrollView.frame.size.height * 0.75, 
                                                  viewController._scrollView.frame.size.width, 
                                                  viewController._scrollView.frame.size.height * 0.25)];
}

- (void)setData:(NSDictionary *)_data
{
  _color = nil;
  data = _data;
  [cells removeAllObjects];
  
  if ([[data objectForKey:@"num_dumbass_tickets"] floatValue] < [[data objectForKey:@"num_tickets"] floatValue] * 0.1)
  {
    [cells addObject:[[StreetSideAttributeCell alloc] initWithText:@"DANGER: No parking machine found"]];
    _color = [UIColor colorWithRed:0.8 green:0.4 blue:0.4 alpha:1.0];
  }
  
  // south side between 7-49
  [cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"addresses between %@-%@\n", //[data objectForKey:@"side"],
                    [[data objectForKey:@"address_range"] objectAtIndex:0], [[data objectForKey:@"address_range"] objectAtIndex:1]]]];
  
  // 748 tickets, average $45.03
  [cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"%d total tickets, average $%.2f\n", 
                  [[data objectForKey:@"num_tickets"] intValue] + 
                  [[data objectForKey:@"num_ignored_tickets"] intValue] + 
                  [[data objectForKey:@"num_dumbass_tickets"] intValue], 
                  [[data objectForKey:@"average_fine"] floatValue]]]];
  
  NSUInteger num_all_tickets = [[data objectForKey:@"num_tickets"] intValue] + [[data objectForKey:@"num_ignored_tickets"] intValue];
  NSUInteger num_unique_infraction_codes = [[data objectForKey:@"infraction_codes"] count] + [[data objectForKey:@"ignored_infraction_codes"] count];
  
  {
    for (NSString * infraction_code in [data objectForKey:@"infraction_codes"])
    {
      NSUInteger count = [[[data objectForKey:@"infraction_codes"] objectForKey:infraction_code] intValue];
      
      // 405 (99.3%) Park-Hwy Prohib Times/Days
      if (count > (num_all_tickets * (3.0 / num_unique_infraction_codes)))
        [cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"%.2f%% %@\n", count / (float)num_all_tickets * 100.0, 
                          [[viewController._meterBeater.infractions objectForKey:infraction_code] capitalizedString]]]];

        //[notes addObject:[NSString stringWithFormat:@"%@ %d (%.1f%%)\n", 
        //                [[viewController._meterBeater.infractions objectForKey:infraction_code] capitalizedString], count, (count / (float)num_all_tickets)*100]];
    }
  }
  
  {
    for (NSString * infraction_code in [data objectForKey:@"ignored_infraction_codes"])
    {
      NSUInteger count = [[[data objectForKey:@"ignored_infraction_codes"] objectForKey:infraction_code] intValue];
      
      // 257 (75.6%) Park - On Boulevard
      if (count > (num_all_tickets * (3.0 / num_unique_infraction_codes)))
        [cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"%.2f%% %@\n", count / (float)num_all_tickets * 100.0, 
                          [[viewController._meterBeater.infractions objectForKey:infraction_code] capitalizedString]]]];

        //[notes addObject:[NSString stringWithFormat:@"%@ %d (%.1f%%)\n", 
        //                [[viewController._meterBeater.infractions objectForKey:infraction_code] capitalizedString], count, (count / (float)num_all_tickets)*100]];
    }
  }
  
  NSArray * wday_names = [NSArray arrayWithObjects:@"sun", @"mon", @"tues", @"wed", @"thurs", @"fri", @"sat", nil];
  //NSArray * wday_names = [NSArray arrayWithObjects:@"sunday", @"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday", nil];
  
  NSMutableArray * safe_streets = [[NSMutableArray alloc] init];
  NSMutableArray * danger_streets = [[NSMutableArray alloc] init];
  
  // fewer tickets issued on sunday
  for (int i = 0 ; i < 7 ; i++)
    if ([[[data objectForKey:@"wday_tickets"] objectAtIndex:i] intValue] < (1.0/7.0 / 2.0) * [[data objectForKey:@"num_tickets"] floatValue])
        [safe_streets addObject:[wday_names objectAtIndex:i]];
      //[cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"%@ seems safe\n", 
      //                  [[[data objectForKey:@"wday_tickets"] objectAtIndex:i] intValue] / [[data objectForKey:@"num_tickets"] floatValue] * 100.0, 
      //                  [wday_names objectAtIndex:i]]]];
  
  // more tickets issued on sunday
  for (int i = 0 ; i < 7 ; i++)
    if ([[[data objectForKey:@"wday_tickets"] objectAtIndex:i] intValue] > (1.0/7.0 * 1.5) * [[data objectForKey:@"num_tickets"] floatValue])
        [danger_streets addObject:[wday_names objectAtIndex:i]];
      //[cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"%@ seems more dangerous\n", 
      //                  [[[data objectForKey:@"wday_tickets"] objectAtIndex:i] intValue] / [[data objectForKey:@"num_tickets"] floatValue] * 100.0, 
      //                  [wday_names objectAtIndex:i]]]];
  
  if ([safe_streets count] == 1)
    [cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"%@. seems safer", [safe_streets objectAtIndex:0]]]];
  else if ([safe_streets count] > 1)
    [cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"%@. seem safer", [safe_streets componentsJoinedByString:@"., "]]]];

  if ([danger_streets count] == 1)
    [cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"%@. seems trickier", [danger_streets objectAtIndex:0]]]];
  else if ([danger_streets count] > 1)
    [cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"%@. seem trickier", [danger_streets componentsJoinedByString:@"., "]]]];

  int wday = [[viewController._meterBeater.data objectForKey:@"wday"] intValue];
  int minutes = [[viewController._meterBeater.data objectForKey:@"minutes"] intValue];
  
  int offset = floor(minutes / 30.0);
  
  int tickets_so_far = 0;
  int too_much = [[data objectForKey:@"num_tickets"] intValue] * (1.5 * (1.0 / (48.0 * 7.0)));
  
  for (int i = -2 ; i < 24 ; i++) // 13 hours
  {
    if (i+offset >= 48) tickets_so_far += [[[[data objectForKey:@"prohibited_tickets_hourly"] objectAtIndex:(wday==6 ? 0 : wday+1)] objectAtIndex:i+offset-48] intValue];
    else tickets_so_far += [[[[data objectForKey:@"prohibited_tickets_hourly"] objectAtIndex:wday] objectAtIndex:i+offset] intValue];
    
    //if (i+offset >= 48) fprintf(stderr, "%d ", [[[[data objectForKey:@"prohibited_tickets_hourly"] objectAtIndex:(wday==6 ? 0 : wday+1)] objectAtIndex:i+offset-48] intValue]);
    //else fprintf(stderr, "%d ", [[[[data objectForKey:@"prohibited_tickets_hourly"] objectAtIndex:wday] objectAtIndex:i+offset] intValue]);
    
    if (tickets_so_far > too_much)
    {
      int temp = (int)floor(minutes/30.0)*30 + (i/2.0*60.0);
      
      int temp_hours = floor(temp / 60.0);
      int temp_minutes = temp - temp_hours*60;
      char * temp_ampm = (temp_hours >= 12 && temp_hours <= 23) ? "pm" : "am";
      while (temp_hours > 12) temp_hours -= 12;
      if (temp_hours == 0) temp_hours = 12;
      //fprintf(stderr, "too much after %.1f half hours (%d:%02d%s)\n", i/2.0, temp_hours, temp_minutes, temp_ampm);
      
      if (i <= 1)
      {
        if (i == 0) [cells addObject:[[StreetSideAttributeCell alloc] initWithText:@"Do NOT park here"]];
        else [cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"Do NOT park after %d:%02d%s", temp_hours, temp_minutes, temp_ampm]]];
        
        if (_color == nil)
          _color = [UIColor colorWithRed:0.8 green:0.4 blue:0.4 alpha:1.0];
      }
      //  [label setText:[NSString stringWithFormat:@"%@You WILL get a ticket here\n", label.text]];
      else
      {
        if (i == 0) [cells addObject:[[StreetSideAttributeCell alloc] initWithText:@"Be careful here"]];
        else [cells addObject:[[StreetSideAttributeCell alloc] initWithText:[NSString stringWithFormat:@"Be careful after %d:%02d%s", temp_hours, temp_minutes, temp_ampm]]];
        //[notes addObject:@"Be careful here"];
        
        if (_color == nil)
          _color = [UIColor colorWithRed:0.8 green:0.8 blue:0.4 alpha:1.0];
      }
      
      //  [label setText:[NSString stringWithFormat:@"%@%@\n", label.text, [NSString stringWithFormat:@"leave before %d:%02d%s",// temp_hours, temp_minutes, temp_ampm]]];
      break;
    }
  }/**/
  
  //if (tickets_so_far > 0) _color = [UIColor colorWithRed:0.8 green:0.8 blue:0.4 alpha:1.0];
  
  if (_color == nil)
    _color = [UIColor colorWithRed:0.4 green:0.8 blue:0.4 alpha:1.0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [cells objectAtIndex:[indexPath indexAtPosition:1]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  //if([tableView indexPathForSelectedRow] && [[tableView indexPathForSelectedRow] isEqual:indexPath])
	//	return 50 + 100;
  
  return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [cells count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView beginUpdates];
  [tableView endUpdates];
  
  //[tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  // Drawing code
}
*/


@end
