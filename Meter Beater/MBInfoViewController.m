//
//  MBInfoViewController.m
//  Meter Beater
//
//  Created by William Hua on 2012-09-03.
//  Copyright (c) 2012 Refactory. All rights reserved.
//

#import "MBInfoViewController.h"

@interface MBInfoViewController () <UIWebViewDelegate>

@property(nonatomic, weak) IBOutlet UIWebView               *webView;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation MBInfoViewController

@synthesize webView;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString     *url  = [NSString stringWithFormat:@"%@%@", [info objectForKey:@"MBAPIAccessHost"], [info objectForKey:@"MBAPIAccessInfoEndpoint"]];
    
#if DEBUG
    NSLog(@"%@", url);
#endif
    
    [[self webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    [[self indicator] setHidesWhenStopped:YES];
}

#pragma mark - UIWebViewDelegate conformance

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[self indicator] startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[self indicator] stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[self indicator] stopAnimating];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet Error" message:@"Something went bad on the Internet." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    
    [alertView show];
}

@end
