//
//  ForgotCredentialsVC.m
//  Forecast
//
//  Created by Cian McLennan on 06/03/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "ForgotCredentialsVC.h"

@interface ForgotCredentialsVC ()

@end

@implementation ForgotCredentialsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Forgot Credentials";
    NSURL*url=[NSURL URLWithString:@"http://www.overcast.fm/forgot"];
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
