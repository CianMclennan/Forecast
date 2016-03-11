//
//  TableCellViewWithMouseInteractions.m
//  Forecast
//
//  Created by Cian McLennan on 12/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "TableCellViewWithMouseInteractions.h"

@implementation TableCellViewWithMouseInteractions

-(void)viewDidMoveToWindow
{
    [[self.deleteButton animator] setAlphaValue:0];
    [[self.downloadButton animator] setAlphaValue:0];
    [[self.infoButton animator] setAlphaValue:0];
    id clipView = [[self enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mouseExited:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

-(void)mouseEntered:(NSEvent *)theEvent {
    if([self.episode.isInLibrary isEqual:@YES])
    {
        [[self.deleteButton animator] setAlphaValue:1];
//        [[self.downloadButton animator] setAlphaValue:1];
        [[self.infoButton animator] setAlphaValue:1];
    }
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [[self.deleteButton animator] setAlphaValue:0];
    [[self.downloadButton animator] setAlphaValue:0];
    [[self.infoButton animator] setAlphaValue:0];
}

-(void)updateTrackingAreas
{
    for (NSTrackingArea* t in self.trackingAreas) {
        [self removeTrackingArea:t];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    
    [self addTrackingArea:[ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                  options:opts
                                                    owner:self
                                                       userInfo:nil]];
}

@end
