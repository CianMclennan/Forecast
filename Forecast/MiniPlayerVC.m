//
//  MiniPlayerVC.m
//  Forecast
//
//  Created by Cian McLennan on 22/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "MiniPlayerVC.h"
#import "OvercastEpisodePlayer.h"
#import "OvercastPodcast.h"

@interface MiniPlayerVC ()

@end

@implementation MiniPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.artwork.image = OvercastEpisodePlayer.sharedPlayer.episode.podcast.bestPodcastArtAvailable;
}

@end
