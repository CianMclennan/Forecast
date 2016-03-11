//
//  PodcastSelectorVC.h
//  Overcast
//
//  Created by Cian McLennan on 02/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NavigableViewController.h"

#define SORT_EPISODES_BY_ORDER_NUMBER @"orderNumber"
#define SORT_EPISODES_BY_PODCAST @"podcast.title"
#define PREDICATE_EPISODES_IN_LIBRARY @"isInLibrary = YES"

@interface EpisodeSelectorVC : NavigableViewController<NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSButton *backButton;
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic) NSFetchRequest* cellFetchRequest;
- (IBAction)infoButtonPressed:(id)sender;
-(void) setCellFetchRequestWithPredicate:(NSString*) predicate sortDescripter:(NSString*) sortDescipter isAccending:(BOOL) accending;
- (IBAction)backButtonPressed:(NSButton *)sender;
- (IBAction)refreshButtonPressed:(id)sender;
@property (strong) IBOutlet NSArrayController *arrayController;

@end
