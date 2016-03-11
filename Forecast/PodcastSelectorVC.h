//
//  PodcastSelectorVC.h
//  Overcast
//
//  Created by Cian McLennan on 02/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NavigableViewController.h"

@interface PodcastSelectorVC : NavigableViewController <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *tableView;
- (IBAction)refreshTableView:(id)sender;
@property (weak) IBOutlet NSButton *backButton;
- (IBAction)backButtonPressed:(id)sender;

@end
