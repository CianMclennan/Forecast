//
//  MediaApplication.m
//  Overcast
//
//  Created by Cian McLennan on 07/01/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "MediaApplication.h"
#import <IOKit/hidsystem/ev_keymap.h>
#import "OvercastEpisodePlayer.h"

@implementation MediaApplication

- (void)sendEvent:(NSEvent *)event
{
    // Catch media key events
    if ([event type] == NSSystemDefined && [event subtype] == 8)
    {
        int keyCode = (([event data1] & 0xFFFF0000) >> 16);
        int keyFlags = ([event data1] & 0x0000FFFF);
        int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
        
        // Process the media key event and return
        [self mediaKeyEvent:keyCode state:keyState];
        return;
    }
    
    // Continue on to super
    [super sendEvent:event];
}

- (void)mediaKeyEvent:(int)key state:(BOOL)state
{
    OvercastEpisodePlayer* player = [OvercastEpisodePlayer sharedPlayer];
    
    switch (key)
    {
            // Play pressed
        case NX_KEYTYPE_PLAY:
            if (state == NO)
                [player togglePlayPause];
            break;
            
            // Rewind
        case NX_KEYTYPE_FAST:
            if (state == YES)
                [player seekForward];
            break;
            
            // Previous
        case NX_KEYTYPE_REWIND:
            if (state == YES)
                [player seekBackward];
            break;
    }
}

@end
