//
//  OvercastEpisodePlayer.h
//  Overcast
//
//  Created by Cian McLennan on 24/01/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerDelegate.h"
#import "OvercastEpisode.h"

#define PLAYER_LOADING_NEW_EPISODE_NOTIFICATION @"PlayerLoadingEpisodeNotification"
#define PLAYER_STARTED_NOTIFICATION             @"PlayerStartedNotification"
#define PLAYER_UPDATED_TIME_NOTIFICATION        @"PlayerUpdatedNotification"
#define PLAYER_UPDATED_PLAY_STATE_NOTIFICATION  @"PlayerStateChangedNotification"
#define PLAYER_DELETE_REQUEST_NOTIFICATION      @"PlayerDeleteRequestNotification"
#define PLAYER_VOLUME_CHANGED_NOTIFICATION      @"PlayerVolumeChangedNotification"
#define PLAYER_RATE_CHANGED_NOTIFICATION        @"PlayerRateChangedNotification"
#define PLAYER_FINISHED_NOTIFICATION            @"PlayerFinishedNotification"

#define PLAYER_KEY @"PlayerKey"

@interface OvercastEpisodePlayer : NSObject

+(OvercastEpisodePlayer*) sharedPlayer;

@property id<PlayerDelegate> delegate;

#pragma mark - Podcast Information getters
@property (readonly) NSString* currentTimeAsString;
@property (readonly) NSString* durationAsString;
@property (readonly) NSString* timeRemainingAsString;
@property (readonly) float timeRemainingInSeconds;
@property (readonly) float durationInSeconds;
@property (readonly) float percentageComplete;
@property (readonly) BOOL playerLoaded;
@property (readonly) BOOL isPlaying;
@property (readonly) OvercastEpisode* episode;

@property (nonatomic) float volume;
@property (nonatomic) float rate;
@property (nonatomic) BOOL shouldDeleteWhenFinished;


#pragma mark - Podcast Information properties
@property float currentTimeInSeconds;

#pragma mark - Player commands
- (void) loadPodcastFromEpisode:(OvercastEpisode*)episode playWhenReady:(BOOL)shouldPlay;
- (void) unloadCurrentEpisode;

- (void) pause;
- (void) play;
- (void) togglePlayPause;

- (void) seekForwardByValue:(NSUInteger) value;
- (void) seekBackwardByValue:(NSUInteger) value;
- (void) seekForward;
- (void) seekBackward;

+ (NSString *)timeFormatted:(int)totalSeconds;
- (NSString *)timeAsStringFromPercentage:(float)percentage;

@end
