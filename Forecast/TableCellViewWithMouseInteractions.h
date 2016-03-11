//
//  TableCellViewWithMouseInteractions.h
//  Forecast
//
//  Created by Cian McLennan on 12/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OvercastEpisode.h"

@interface TableCellViewWithMouseInteractions : NSTableCellView
@property (weak) IBOutlet NSButton *deleteButton;
@property (weak) IBOutlet NSButton *downloadButton;
@property (weak) IBOutlet NSButton *infoButton;
@property (weak) IBOutlet NSTextField *timeRemainingTextField;
@property OvercastEpisode* episode;
@property BOOL isActiveEpisode;

@end
