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

+ (NSString *)MB_host
{
    static NSString *host = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        host = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"MBAPIAccessHost"];
    });
    
    return host;
}

+ (NSString *)MB_version
{
    static NSString *version = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"MBAPIAccessVersion"];
    });
    
    return version;
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

+ (void)cancelPendingRequests
{
    for(MBAPIAccess *connection in [self MB_connections])
        [connection cancel];
    
    [[self MB_connections] removeAllObjects];
}

+ (NSURL *)requestURLWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/test3.json?v=%@&lat=%f&lng=%f", [[self class] MB_host], [[self class] MB_version], latitude, longitude]];
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

- (void)cancel
{
    [owner cancel];
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
