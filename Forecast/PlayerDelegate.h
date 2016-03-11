//
//  PlayerDelegate.h
//  Overcast
//
//  Created by Cian McLennan on 05/01/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerDelegate <NSObject>

@optional -(void) playerWillChangePodcast;
@optional -(void) playerDidPausePlayback;
@optional -(void) playerDidResumePlayback;
@optional -(void) playerDidBeginPlayback;
@optional -(void) playerTimerUpdated:(float)currentTimeInSeconds currentTimeAsString:(NSString*)currentTimeString percentageComplete:(float)percentageComplete;

@optional -(void) playerDidFinish;
@optional -(void) playerDidSendDeleteRequest;
@optional -(void) playerVolumeDidChange:(float) volume;
@optional -(void) playerRateDidChange:(float) rate;
@end
