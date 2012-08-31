//
//  MBAddress.m
//  mb
//
//  Created by William Hua on 2012-08-30.
//  Copyright (c) 2012 Refactory. All rights reserved.
//

#import "MBAddress.h"

static NSString * const MBAddressIdentifierKey = @"id";
static NSString * const MBAddressVerticesKey   = @"polyline";
static NSString * const MBAddressValuesKey     = @"tickets";

@implementation MBAddress

@synthesize identifier, vertices, values;

+ (id)addressWithDictionary:(NSDictionary *)dictionary
{
    return [[[self class] alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if((self = [super init]))
    {
        [self setIdentifier:[dictionary objectForKey:MBAddressIdentifierKey]];
        
        NSArray        *array        = [dictionary objectForKey:MBAddressVerticesKey];
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[array count]];
        
        for(NSArray *pair in array)
            [mutableArray addObject:[NSValue valueWithCGPoint:CGPointMake([[pair objectAtIndex:0] floatValue], [[pair objectAtIndex:1] floatValue])]];
        
        [self setVertices:mutableArray];
        
        [self setValues:[dictionary objectForKey:MBAddressValuesKey]];
    }
    
    return self;
}

@end
