//
//  TableCellViewWithMouseInteractionsWithGradient.m
//  Forecast
//
//  Created by Cian McLennan on 24/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "TableCellViewWithMouseInteractionsWithGradient.h"

@implementation TableCellViewWithMouseInteractionsWithGradient

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:self.startColour
                             endingColor:self.endColour];
    [aGradient drawInRect:[self bounds] angle:0];
}

@end
