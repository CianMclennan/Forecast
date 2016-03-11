//
//  EpisodeNavigationVC.m
//  Forecast
//
//  Created by Cian McLennan on 10/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "EpisodeNavigationVC.h"
#import "EpisodeSelectorVC.h"
#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>

@interface EpisodeNavigationVC ()

@end

@implementation EpisodeNavigationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    EpisodeSelectorVC* episodeVC = (EpisodeSelectorVC*)[self navigateToViewControllerWithIdentifier:@"EpisodeView" inStoryboardWithName:@"Main"];
    [episodeVC setCellFetchRequestWithPredicate:PREDICATE_EPISODES_IN_LIBRARY sortDescripter:SORT_EPISODES_BY_PODCAST isAccending:YES];
}
@end
