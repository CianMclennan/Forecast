//
//  OvercastEpisodePlayer.m
//  Overcast
//
//  Created by Cian McLennan on 24/01/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "OvercastEpisodePlayer.h"
#import "OvercastSession.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

#define SERVER_UPDATE_TIME_INTERVAL 6
#define PLAYER_VOLUME_KEY @"playerVolume"
#define PLAYER_RATE_KEY @"playerRate"

@implementation OvercastEpisodePlayer
{
    AVPlayer*           _audioPlayer;
    NSTimer*            _currentTimeTrackingInterval;
    float               _previousTime; // for the tracking of current podcast Time
    BOOL                _hasBegunPlaying;
    OvercastEpisode*    _episode;
    NSUInteger          _syncCount;
    float               _rate;
}

#pragma mark - Singleton Methods
+(OvercastEpisodePlayer*) sharedPlayer {
    static OvercastEpisodePlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[self alloc] init];
    });
    return player;
}

- (id)init {
    if (self = [super init]) {
        _hasBegunPlaying = NO;
        _syncCount = 0;
        _rate = 1;
        self.shouldDeleteWhenFinished = YES;
        _currentTimeTrackingInterval = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                              target:self
                                                                            selector:@selector(updateCurrentTimeTracking:)
                                                                            userInfo:nil
                                                                             repeats:YES];
    }
    return self;
}

#pragma mark - Player Commands
-(void)loadMP3withURL:(NSURL *)url playWhenReady:(BOOL)shouldPlay
{
    _audioPlayer = nil;
    
    _hasBegunPlaying = NO;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    _audioPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    if (shouldPlay) {
        [self play];
    }
    
    NSString* storedVolume = [[NSUserDefaults standardUserDefaults] objectForKey:PLAYER_VOLUME_KEY];
    
    self.volume = storedVolume ? [storedVolume floatValue] : 100;
}
-(void)loadMP3withURLString:(NSString *)urlString playWhenReady:(BOOL)shouldPlay
{
    NSURL *url = [NSURL URLWithString:urlString];
    [self loadMP3withURL:url playWhenReady:shouldPlay];
}

- (void) loadPodcastFromEpisode:(OvercastEpisode* _Nonnull)newEpisode playWhenReady:(BOOL)shouldPlay
{
    NSString* podcastFileUrl = newEpisode.audioFileURL;
    [self loadMP3withURLString:podcastFileUrl playWhenReady:shouldPlay];
    _episode = newEpisode;
    float startTime = [_episode.startTime floatValue];
    self.currentTimeInSeconds = startTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_LOADING_NEW_EPISODE_NOTIFICATION
                                                        object:self
                                                      userInfo:@{PLAYER_KEY: self}];
}

-(void) unloadCurrentEpisode
{
    _episode = nil;
    _audioPlayer = nil;
}

-(void)play
{
    _audioPlayer.rate = _rate;
    if (_hasBegunPlaying)
    {
        if([self.delegate respondsToSelector:@selector(playerDidResumePlayback)])
            [self.delegate playerDidResumePlayback];
        [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_UPDATED_PLAY_STATE_NOTIFICATION
                                                            object:self
                                                          userInfo:@{PLAYER_KEY: self}];
    }
}

-(void)pause
{
    [_audioPlayer pause];
    if (_audioPlayer) {
        if([self.delegate respondsToSelector:@selector(playerDidPausePlayback)])
            [self.delegate playerDidPausePlayback];
        [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_UPDATED_PLAY_STATE_NOTIFICATION
                                                            object:self
                                                          userInfo:@{PLAYER_KEY: self}];
    }
}

-(void)togglePlayPause
{
    self.isPlaying ? [self pause] : [self play];
}

-(void)setCurrentTimeInSeconds:(float)currentTimeInSeconds
{
    CMTime newTime = CMTimeMakeWithSeconds(currentTimeInSeconds, 600);
    [_audioPlayer seekToTime:newTime];
}
-(void)seekForwardByValue:(NSUInteger)value
{
    self.currentTimeInSeconds += value;
}
-(void)seekBackwardByValue:(NSUInteger)value
{
    self.currentTimeInSeconds -= value;
}
-(void)seekForward
{
    self.currentTimeInSeconds += [self seekForwardValue];
}
-(void)seekBackward
{
    self.currentTimeInSeconds -= [self seekBackwardValue];
}
-(float) seekForwardValue
{
    return _episode.seekForwardValue ? [_episode.seekForwardValue floatValue] : 30;
}
-(float) seekBackwardValue
{
    return _episode.seekBackwardValue ? [_episode.seekBackwardValue floatValue] : 30;
}

#pragma mark - Player Info
-(BOOL)isPlaying
{
    return _audioPlayer.rate > 0 && (_audioPlayer.error == nil);
}
-(float)currentTimeInSeconds
{
    return CMTimeGetSeconds(_audioPlayer.currentItem.currentTime);
}

-(float)durationInSeconds
{
    return CMTimeGetSeconds(_audioPlayer.currentItem.asset.duration);
}
-(float)timeRemainingInSeconds
{
    return self.durationInSeconds - self.currentTimeInSeconds;
}

-(float) percentageComplete
{
    float currentTime = [self currentTimeInSeconds];
    float duration = [self durationInSeconds];
    return (currentTime/duration)*100;
}
-(NSString *)currentTimeAsString
{
    return [OvercastEpisodePlayer timeFormatted:(int) self.currentTimeInSeconds];
}
-(NSString *)durationAsString
{
    return [OvercastEpisodePlayer timeFormatted:(int) self.durationInSeconds];
}
-(NSString *)timeRemainingAsString
{
    return [OvercastEpisodePlayer timeFormatted:(int) self.timeRemainingInSeconds];
}

#pragma mark - Timer Methods

#define PLAYER_CURRENT_EPISODE
- (void) updateCurrentTimeTracking:(NSTimer *)timer
{
    if (!_audioPlayer) {
        return;
    }
    if (_previousTime == [self currentTimeInSeconds]) {
        return;
    }
    else if(!_hasBegunPlaying)
    {
        _hasBegunPlaying = YES;
        _episode.hasBegunPlaying = @YES;
        if([self.delegate respondsToSelector:@selector(playerDidBeginPlayback)])
            [self.delegate playerDidBeginPlayback];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_STARTED_NOTIFICATION
                                                            object:self
                                                          userInfo:@{PLAYER_KEY: self}];
    }
    _episode.startTime = [NSString stringWithFormat:@"%f", self.currentTimeInSeconds];
    _previousTime = [self currentTimeInSeconds];
    if ([[self delegate] respondsToSelector:@selector(playerTimerUpdated:currentTimeAsString:percentageComplete:)]) {
        [self.delegate playerTimerUpdated:self.currentTimeInSeconds currentTimeAsString:self.currentTimeAsString percentageComplete:self.percentageComplete];
    }
    if(_episode && self.isPlaying)
    {
        _episode.timeRemaing = self.timeRemainingAsString;
        [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_UPDATED_TIME_NOTIFICATION
                                                            object:self
                                                          userInfo:@{PLAYER_KEY: self}];
    }
    
    if(_syncCount++ > SERVER_UPDATE_TIME_INTERVAL)
    {
        [[OvercastSession sharedSession] sendRequest:[_episode getUpdateRequestWithProgress:self.currentTimeInSeconds]
                               withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
         {
             @try {
                 NSString* dataAsString = [ NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
                 NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                 f.numberStyle = NSNumberFormatterDecimalStyle;
                 NSNumber *syncVersionAsNumber = [f numberFromString:dataAsString];
                 _episode.syncVersion = syncVersionAsNumber ? [syncVersionAsNumber stringValue] : 0;
             }
             @catch (NSException *exception) {
                 NSLog(@"Unable to back up to the Server");
             }
             
         }];
        _syncCount = 0;
    }
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    if ([[self delegate] respondsToSelector:@selector(playerDidFinish)]){
        [[self delegate] playerDidFinish];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_FINISHED_NOTIFICATION
                                                        object:self
                                                      userInfo:@{PLAYER_KEY: self}];
    self.currentTimeInSeconds = 0;
    if(self.shouldDeleteWhenFinished)
    {
        NSURL* url = _episode.deletePodcastURL;
        if (url)
        {
            [[OvercastSession sharedSession] sendRequestToUrl:url withCompletionHandler:nil];
            if ([self.delegate respondsToSelector:@selector(playerDidSendDeleteRequest)]) {
                [self.delegate playerDidSendDeleteRequest];
            }
        }
    }
}

- (NSString *)timeAsStringFromPercentage:(float)percentage
{
    float duration = [self durationInSeconds];
    float timeAsFloat = duration*(percentage/100);
    return [OvercastEpisodePlayer timeFormatted:(int)timeAsFloat];
}

-(float)volume
{
    return _audioPlayer.volume ? _audioPlayer.volume : [[[NSUserDefaults standardUserDefaults] objectForKey:PLAYER_VOLUME_KEY] floatValue];
}
-(void)setVolume:(float)volume
{
    _audioPlayer.volume = volume;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", volume] forKey:PLAYER_VOLUME_KEY];
    if ([self.delegate respondsToSelector:@selector(playerVolumeDidChange:)]) {
        [self.delegate playerVolumeDidChange:_audioPlayer.volume];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_VOLUME_CHANGED_NOTIFICATION
                                                        object:self
                                                      userInfo:@{PLAYER_KEY: self}];
}

-(float)rate
{
    return _rate;
}
-(void)setRate:(float)rate
{
    if(self.isPlaying)
        _audioPlayer.rate = _rate = rate;
    else
        _rate = rate;
    if ([self.delegate respondsToSelector:@selector(playerRateDidChange:)]) {
        [self.delegate playerRateDidChange:_rate];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_RATE_CHANGED_NOTIFICATION
                                                        object:self
                                                      userInfo:@{PLAYER_KEY: self}];
}

#pragma mark - Helper Methods

+ (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    NSString* string = [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    if ([[string substringToIndex:3] isEqualToString:@"00:"])
    {
        string = [string substringFromIndex:3];
    }
    return string;
}

@end