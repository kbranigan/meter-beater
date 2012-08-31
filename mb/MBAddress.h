//
//  MBAddress.h
//  mb
//
//  Created by William Hua on 2012-08-30.
//  Copyright (c) 2012 Refactory. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBAddress : NSObject

@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSArray  *vertices;
@property(nonatomic, copy) NSArray  *values;

+ (id)addressWithDictionary:(NSDictionary *)dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
