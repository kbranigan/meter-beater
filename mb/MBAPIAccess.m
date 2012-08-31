//
//  MBAPIAccess.m
//  mb
//
//  Created by William Hua on 2012-08-30.
//  Copyright (c) 2012 Refactory. All rights reserved.
//

#import "MBAPIAccess.h"

@interface MBAPIAccess () <NSURLConnectionDataDelegate>

@end

@implementation MBAPIAccess
{
    NSURLConnection *owner;
    NSMutableData   *buffer;
    
    void (^block)(NSDictionary *, NSError *);
}

+ (NSMutableSet *)MB_connections
{
    static NSMutableSet *connections = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        connections = [NSMutableSet set];
    });
    
    return connections;
}

+ (NSURL *)requestURLWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.1.110:3333/near?lat=%f&lng=%f", latitude, longitude]];
}

+ (void)requestObjectWithURL:(NSURL *)url completionBlock:(void (^)(NSDictionary *, NSError *))blk
{
    [self APIAccessWithURL:url completionBlock:blk];
}

+ (id)APIAccessWithURL:(NSURL *)url completionBlock:(void (^)(NSDictionary *, NSError *))blk
{
    return [[[self class] alloc] initWithURL:url completionBlock:blk];
}

- (id)initWithURL:(NSURL *)url completionBlock:(void (^)(NSDictionary *, NSError *))blk
{
    if((self = [super init]))
    {
        [[[self class] MB_connections] addObject:self];
        
        buffer = [NSMutableData data];
        
        owner = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
        
        block = blk;
    }
    
    return self;
}

#pragma mark - NSURLConnectionDataDelegate conformance

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(connection == owner)
        [buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    
    id object = [NSJSONSerialization JSONObjectWithData:buffer options:0 error:&error];
    
    block(object, error);
    
    [[[self class] MB_connections] removeObject:self];
}

@end
