//
//  PodcastNavigationVC.m
//  Forecast
//
//  Created by Cian McLennan on 09/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "PodcastNavigationVC.h"

@interface PodcastNavigationVC ()

@end

@implementation PodcastNavigationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigateToViewControllerWithIdentifier:@"PodcastView" inStoryboardWithName:@"Main"];
}

@end
