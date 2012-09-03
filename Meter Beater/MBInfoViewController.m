//
//  MBInfoViewController.m
//  Meter Beater
//
//  Created by William Hua on 2012-09-03.
//  Copyright (c) 2012 Refactory. All rights reserved.
//

#import "MBInfoViewController.h"

@interface MBInfoViewController ()

@property(nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation MBInfoViewController

@synthesize webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString     *url  = [NSString stringWithFormat:@"%@%@", [info objectForKey:@"MBAPIAccessHost"], [info objectForKey:@"MBAPIAccessInfoEndpoint"]];
    
#if DEBUG
    NSLog(@"%@", url);
#endif
    
    [[self webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

@end
