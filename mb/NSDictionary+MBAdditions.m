//
//  NSDictionary+MBAdditions.m
//  mb
//
//  Created by William Hua on 2012-09-01.
//  Copyright (c) 2012 Refactory. All rights reserved.
//

#import "NSDictionary+MBAdditions.h"

@implementation NSDictionary (MBAdditions)

- (id)objectForKeyPath:(NSString *)keyPath
{
    NSArray *components = [keyPath componentsSeparatedByString:@"."];
    id       value      = self;
    
    for(NSString *component in components)
    {
        if([value isKindOfClass:[NSDictionary class]])
            value = [value objectForKey:component];
        else
            return nil;
    }
    
    return value;
}

@end
