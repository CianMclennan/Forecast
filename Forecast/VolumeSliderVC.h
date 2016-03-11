//
//  volumeSliderVC.h
//  Forecast
//
//  Created by Cian McLennan on 15/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VolumeSliderVC : NSViewController
@property (weak) IBOutlet NSSlider *slider;
- (IBAction)sliderDidChange:(NSSlider *)sender;

@end
