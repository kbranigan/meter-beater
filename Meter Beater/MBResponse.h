//
//  MBResponse.h
//  mb
//
//  Created by William Hua on 2012-08-30.
//  Copyright (c) 2012 Refactory. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MBAddress.h"

@interface MBResponse : NSObject

@property(nonatomic, copy) NSArray *ranges;
@property(nonatomic, copy) NSArray *addresses;
@property(nonatomic)       CGRect   region;

+ (id)responseWithDictionary:(NSDictionary *)dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
