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

@implementation MBResponse

@synthesize ranges, addresses;

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
    }
    
    return self;
}

@end