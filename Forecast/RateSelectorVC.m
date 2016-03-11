//
//  RateSelectorVC.m
//  Forecast
//
//  Created by Cian McLennan on 15/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "RateSelectorVC.h"
#import "OvercastEpisodePlayer.h"

@implementation RateSelectorVC

- (IBAction)rateChangeButtonPressed:(NSButton *)sender {
    float rateChangeVal = [[sender.title substringFromIndex:1] floatValue];
    [OvercastEpisodePlayer sharedPlayer].rate = rateChangeVal;
}
@end
