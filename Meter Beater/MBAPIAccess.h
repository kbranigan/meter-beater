//
//  MBAPIAccess.h
//  mb
//
//  Created by William Hua on 2012-08-30.
//  Copyright (c) 2012 Refactory. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBAPIAccess : NSObject

+ (void)cancelPendingRequests;

+ (NSURL *)requestURLWithPayment:(NSString*)payment latitude:(CGFloat)latitude longitude:(CGFloat)longitude;

+ (void)requestObjectWithURL:(NSURL *)url completionBlock:(void (^)(NSDictionary *, NSError *))blk;

@end
