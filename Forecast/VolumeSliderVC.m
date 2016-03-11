//
//  volumeSliderVC.m
//  Forecast
//
//  Created by Cian McLennan on 15/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "VolumeSliderVC.h"
#import "OvercastEpisodePlayer.h"
@implementation VolumeSliderVC

-(void)viewDidLoad
{
    self.slider.continuous = YES;
    self.slider.floatValue = [OvercastEpisodePlayer sharedPlayer].volume;
}

- (IBAction)sliderDidChange:(NSSlider *)sender {
    [OvercastEpisodePlayer sharedPlayer].volume = self.slider.floatValue;
}
@end
