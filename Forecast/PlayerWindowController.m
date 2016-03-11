//
//  PlayerWindowController.m
//  taskbarTest
//
//  Created by Cian McLennan on 06/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "PlayerWindowController.h"
#import "OvercastEpisodePlayer.h"
#import "OvercastPodcast.h"
#import "AppDelegate.h"

@interface PlayerWindowController ()

@end

@implementation PlayerWindowController
{
    OvercastEpisodePlayer* _player;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    _player = [OvercastEpisodePlayer sharedPlayer];
//    _player.delegate = self;
    self.progressSlider.continuous = YES;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:REQUEST_SENT_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self.progressSpinner startAnimation:self];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:REQUEST_RESPONSE_RECIVED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self.progressSpinner stopAnimation:self];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:PLAYER_STARTED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
//                                                      OvercastEpisodePlayer* player = note.userInfo[PLAYER_KEY];
                                                      [self playerDidBeginPlayback];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:PLAYER_LOADING_NEW_EPISODE_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self playerDidBeginPlayback];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:PLAYER_UPDATED_TIME_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      OvercastEpisodePlayer* player = note.userInfo[PLAYER_KEY];
                                                      [self playerTimerUpdated:player.currentTimeInSeconds currentTimeAsString:player.currentTimeAsString percentageComplete:player.percentageComplete];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:PLAYER_UPDATED_PLAY_STATE_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      OvercastEpisodePlayer* player = note.userInfo[PLAYER_KEY];
                                                      player.isPlaying ? [self playerDidResumePlayback] : [self playerDidPausePlayback];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:PLAYER_RATE_CHANGED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      OvercastEpisodePlayer* player = note.userInfo[PLAYER_KEY];
                                                      [self playerRateDidChange:player.rate];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:PLAYER_FINISHED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
//                                                      OvercastEpisodePlayer* player = note.userInfo[PLAYER_KEY];
                                                      [self playerDidFinish];
                                                  }];
}
- (IBAction)seekForwardButtonPressed:(NSButton *)sender {
    [_player seekForward];
}

- (IBAction)seekBackwardButtonPressed:(NSButton *)sender {
    [_player seekBackward];
}

- (IBAction)playPauseButtonPressed:(NSButton *)sender {
    [_player togglePlayPause];
}

- (IBAction)podcastArtworkPressed:(NSButtonCell *)sender {
    NSLog(@"Artwork Pressed");
}

-(void)playerDidBeginPlayback
{
    self.podcastArtwork.image = _player.episode.podcast.bestPodcastArtAvailable;
    self.window.title = _player.episode.title;
    NSString* seekBackVal = _player.episode.seekBackwardValue;
    NSString* seekForwardVal = _player.episode.seekForwardValue;
    self.seekBackwardButton.title = seekBackVal ? seekBackVal : @"30";
    self.seekForwardButton.title = seekForwardVal ? seekForwardVal : @"30";
    self.playPauseButton.image = [NSImage imageNamed: _player.isPlaying ? @"pauseBtn" : @"playBtn"];
    self.progressSlider.doubleValue = _player.percentageComplete;
    self.podcastCurrentTimeTF.stringValue = _player.currentTimeAsString;
    self.podcastDurationTF.stringValue = [NSString stringWithFormat:@"-%@", _player.timeRemainingAsString];
}

-(void)playerDidFinish
{
    self.playPauseButton.image = [NSImage imageNamed: @"playBtn"];
}
-(void)playerDidPausePlayback
{
    self.playPauseButton.image = [NSImage imageNamed: @"playBtn"];
}
-(void)playerDidResumePlayback
{
    self.playPauseButton.image = [NSImage imageNamed: @"pauseBtn"];
}
-(void)playerTimerUpdated:(float)currentTimeInSeconds currentTimeAsString:(NSString *)currentTimeString percentageComplete:(float)percentageComplete
{
    self.progressSlider.doubleValue = percentageComplete;
    self.podcastCurrentTimeTF.stringValue = _player.currentTimeAsString;
    self.podcastDurationTF.stringValue = [NSString stringWithFormat:@"-%@", _player.timeRemainingAsString];
}
-(void)playerRateDidChange:(float)rate
{
    self.rateChangeButton.title = [NSString stringWithFormat:fmodf(rate, 1.0f) ? @"x%.01f" : @"x%.f", rate];
}

- (IBAction)sliderUpdated:(NSSlider *)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
//    BOOL startingDrag = event.type == NSLeftMouseDown;
    BOOL dragging = event.type == NSLeftMouseDragged;
    BOOL endingDrag = event.type == NSLeftMouseUp;

    if (endingDrag)
    {
        float newTime = (_player.durationInSeconds* sender.floatValue)/100;
        _player.currentTimeInSeconds = newTime;
    }
    if (dragging)
    {
        self.podcastCurrentTimeTF.stringValue = [_player timeAsStringFromPercentage:sender.floatValue];
    }
}

@end
