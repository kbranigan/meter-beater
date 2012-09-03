//
//  MBResponse.m
//  mb
//
//  Created by William Hua on 2012-08-30.
//  Copyright (c) 2012 Refactory. All rights reserved.
//

#import "MBResponse.h"
#import "NSDictionary+MBAdditions.h"

static NSString * const MBResponseRangesKey    = @"params.range_in_minutes";
static NSString * const MBResponseAddressesKey = @"addresses";
static NSString * const MBResponseRegionKey    = @"bbox";

@implementation MBResponse

@synthesize ranges, addresses, region;

+ (id)responseWithDictionary:(NSDictionary *)dictionary
{
    return [[[self class] alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if((self = [super init]))
    {
        [self setRanges:[dictionary objectForKeyPath:MBResponseRangesKey]];
        
        NSArray        *array        = [dictionary objectForKeyPath:MBResponseAddressesKey];
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[array count]];
        
        for(NSDictionary *dictionary in array)
            [mutableArray addObject:[MBAddress addressWithDictionary:dictionary]];
        
        [self setAddresses:mutableArray];
        
        array = [dictionary objectForKeyPath:MBResponseRegionKey];
        
        CGRect rect = CGRectZero;
        
        if([array count] > 0)
        {
            NSArray *subarray = [array objectAtIndex:0];
            
            if([subarray count] > 0)
                rect.origin.x = [[subarray objectAtIndex:0] floatValue];
            if([subarray count] > 1)
                rect.origin.y = [[subarray objectAtIndex:1] floatValue];
        }
        if([array count] > 1)
        {
            NSArray *subarray = [array objectAtIndex:1];
            
            if([subarray count] > 0)
                rect.size.width  = [[subarray objectAtIndex:0] floatValue] - rect.origin.x;
            if([subarray count] > 1)
                rect.size.height = [[subarray objectAtIndex:1] floatValue] - rect.origin.y;
        }
        
        [self setRegion:rect];
    }
    
    return self;
}

@end
