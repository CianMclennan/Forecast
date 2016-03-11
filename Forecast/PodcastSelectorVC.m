//
//  PodcastSelectorVC.m
//  Overcast
//
//  Created by Cian McLennan on 02/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "PodcastSelectorVC.h"
#import "EpisodeSelectorVC.h"
#import "OvercastPodcast.h"
#import "AppDelegate.h"
#import "OvercastSession.h"

#define CURRENT_PODCAST_KEY @"currentPodcast"

@implementation PodcastSelectorVC
{
    NSArray*                _podcastArray;
    NSManagedObjectContext* _managedObjectContext;
    AppDelegate*            _appDelegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    _managedObjectContext = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    [[NSNotificationCenter defaultCenter] addObserverForName:MANAGED_OBJECT_CONTEXT_UPDATED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self loadPodcasts];
                                                  }];
    
    [self.tableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [[self.tableView.tableColumns firstObject] setResizingMask:NSTableColumnAutoresizingMask];
    [self.tableView sizeLastColumnToFit];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.target = self;
    self.tableView.action = @selector(podcastSelected:);
    
    _appDelegate = [[NSApplication sharedApplication] delegate];
}

-(void)viewDidAppear
{
//    [self loadPodcasts];
}

-(void) loadPodcasts
{
    if(![[OvercastSession sharedSession] isLoggedIn])
    {
        _podcastArray = [[NSArray alloc] init];
        [self.tableView reloadData];
        return;
    }
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"OvercastPodcast"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    NSError *error;
    NSArray* results = [_managedObjectContext executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"%@", error);
    }
    else{
        _podcastArray = [results copy];
        [self.tableView reloadData];
    }
}

-(void) podcastSelected:(id) sender
{
    if (_podcastArray.count-1 <= self.tableView.selectedRow) return;
    OvercastPodcast* podcast = _podcastArray[self.tableView.selectedRow];
    if (!podcast.overcastURL) return;
    EpisodeSelectorVC* episodeView = (EpisodeSelectorVC*)[self.navigationViewContoller navigateToViewControllerWithIdentifier:@"EpisodeView" inStoryboardWithName:@"Main"];
    NSString* episodesWithPodcastTitle = [NSString stringWithFormat: @"podcast.title = \"%@\"", podcast.title];
    [episodeView setCellFetchRequestWithPredicate:episodesWithPodcastTitle sortDescripter:SORT_EPISODES_BY_ORDER_NUMBER isAccending:YES];
    
    [_appDelegate sendRequestWithURLString:podcast.overcastURL];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _podcastArray.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView* cellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    
    OvercastPodcast* podcast = [_podcastArray objectAtIndex:row];
    
    NSString* title = podcast.title;

    [cellView.textField setStringValue:title];
    [cellView.imageView setImage:podcast.bestPodcastArtAvailable];
    
    return cellView;
}

- (IBAction)refreshTableView:(id)sender {
    
}

- (IBAction)backButtonPressed:(id)sender {
}

-(void)wasNavigatedTo
{
    if(self.isFirstControllerInStack)
    {
        self.backButton.enabled = false;
        self.backButton.alphaValue = 0;
    }
}

@end
