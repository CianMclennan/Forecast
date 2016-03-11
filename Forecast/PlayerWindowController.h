//
//  PlayerWindowController.h
//  taskbarTest
//
//  Created by Cian McLennan on 06/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlayerDelegate.h"

@interface PlayerWindowController : NSWindowController <PlayerDelegate>
@property (weak) IBOutlet NSButton *seekBackwardButton;
@property (weak) IBOutlet NSButton *seekForwardButton;
@property (weak) IBOutlet NSButton *playPauseButton;
@property (weak) IBOutlet NSToolbar *toolBar;
@property (weak) IBOutlet NSSlider *progressSlider;
@property (weak) IBOutlet NSTextField *podcastDurationTF;
@property (weak) IBOutlet NSTextField *podcastCurrentTimeTF;
@property (weak) IBOutlet NSButtonCell *podcastArtwork;
@property (weak) IBOutlet NSProgressIndicator *progressSpinner;
@property (weak) IBOutlet NSButton *rateChangeButton;

- (IBAction)seekForwardButtonPressed:(NSButton *)sender;
- (IBAction)seekBackwardButtonPressed:(NSButton *)sender;
- (IBAction)playPauseButtonPressed:(NSButton *)sender;
- (IBAction)podcastArtworkPressed:(NSButtonCell *)sender;
- (IBAction)sliderUpdated:(NSSlider *)sender;

@end
