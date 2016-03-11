//
//  PodcastSelectorVC.m
//  Overcast
//
//  Created by Cian McLennan on 02/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "EpisodeSelectorVC.h"
#import "OvercastPodcast.h"
#import "OvercastEpisode.h"
#import "OvercastEpisodePlayer.h"
#import "OvercastSession.h"
#import "AppDelegate.h"
#import "TableCellViewWithMouseInteractions.h"

@implementation EpisodeSelectorVC{
    NSArray* _episodeArray;
    NSArray* _podcastArray;
    NSManagedObjectContext* _managedObjectContext;
    AppDelegate* _appDelegate;
    NSPredicate* _searchPredicate;
    
    OvercastEpisode* _playEpisode;
    id<NSObject> _playEpisodeNotification;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _managedObjectContext = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    [[NSNotificationCenter defaultCenter] addObserverForName:MANAGED_OBJECT_CONTEXT_UPDATED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self loadEpisodes];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:PLAYER_UPDATED_TIME_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      OvercastEpisodePlayer* player = note.userInfo[PLAYER_KEY];
                                                      for(NSUInteger i = 0; i < _episodeArray.count; i++)
                                                      {
                                                          OvercastEpisode* episode = self.filteredEpisodes[i];
                                                          if ([episode.uniqueID isEqualToString:player.episode.uniqueID]) {
                                                              [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:i]
                                                                                        columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                                                              break;
                                                          }
                                                      }
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:PLAYER_LOADING_NEW_EPISODE_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self.tableView reloadData];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:INTERNET_CONNECTION_CHANGED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      if(_appDelegate.online) {
                                                          [_appDelegate sendRequestWithURLString:OVERCAST_REQUEST_MAIN_PAGE];
                                                      }
                                                  }];
    
    [self.tableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [[self.tableView.tableColumns firstObject] setResizingMask:NSTableColumnAutoresizingMask];
    [self.tableView sizeLastColumnToFit];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.target = self;
    self.tableView.action = @selector(episodeSelected:);
    
    _searchPredicate = [NSPredicate predicateWithFormat:@"(title contains[cd] $value) or (podcast.title contains[cd] $value)"];
    
    _appDelegate = [[NSApplication sharedApplication] delegate];
}

- (IBAction)searchPredicateChanged:(id)sender {
    NSString* string = [sender stringValue];
    NSPredicate* predicate = nil;
    if (string.length != 0) {
        NSDictionary *dict = @{@"value": string};
        predicate = [_searchPredicate predicateWithSubstitutionVariables:dict];
    }
    [self.arrayController setFilterPredicate:predicate];
    [self.tableView reloadData];
}
-(NSArray*) filteredEpisodes
{
    return [self.arrayController arrangeObjects:_episodeArray];
}

-(void)viewDidAppear
{
//    [self loadEpisodes];
}

-(void) loadEpisodes
{
    if(![[OvercastSession sharedSession] isLoggedIn] || !self.cellFetchRequest)
    {
        _episodeArray = [[NSArray alloc] init];
        [self.tableView reloadData];
        return;
    }
    NSFetchRequest* request = self.cellFetchRequest;
    
    NSError *error;
    NSArray* results = [_managedObjectContext executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"%@", error);
    }
    else{
        _episodeArray = [results copy];
        [self.tableView reloadData];
    }
}

-(void) episodeSelected:(id) sender
{
    if ([self.arrayController arrangeObjects:_episodeArray].count-1 <= self.tableView.selectedRow) return;
    OvercastEpisode* episode = [self.arrayController arrangeObjects:_episodeArray][self.tableView.selectedRow];
    [self.tableView deselectAll:self];
    if (!_appDelegate.online) return;
    _appDelegate.currentPodcastID = episode.uniqueID;
    
    if (episode.audioFileURL.length > 0)
    {
        [[OvercastEpisodePlayer sharedPlayer] loadPodcastFromEpisode:episode playWhenReady:YES];
    }
    else
    {
        _playEpisodeNotification = [[NSNotificationCenter defaultCenter] addObserverForName:EPISODE_INFO_LOADED_NOTIFICATION
                                                                                     object:nil
                                                                                      queue:nil
                                                                                 usingBlock:^(NSNotification * _Nonnull note) {
                                                                                     OvercastEpisode* episode = note.userInfo[EPISODE_USER_INFO_KEY];
                                                                                     if ([episode.uniqueID isEqualToString:_playEpisode.uniqueID]) {
                                                                                         [[OvercastEpisodePlayer sharedPlayer] loadPodcastFromEpisode:episode playWhenReady:YES];
                                                                                         [[NSNotificationCenter defaultCenter] removeObserver:_playEpisodeNotification];
                                                                                         _playEpisodeNotification = nil;
                                                                                         _playEpisode = nil;
                                                                                     }
                                                                                 }];
        _playEpisode = episode;
        [[[NSApplication sharedApplication] delegate] sendRequestWithURLString:episode.overcastURL];
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.filteredEpisodes.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    TableCellViewWithMouseInteractions* cellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    
    OvercastEpisode* episode = [self.filteredEpisodes objectAtIndex:row];
    if([episode.uniqueID isEqualToString:[OvercastEpisodePlayer sharedPlayer].episode.uniqueID])
    {
        cellView = [tableView makeViewWithIdentifier:@"ActiveCell" owner:self];
    }
    else
    {
        cellView = [tableView makeViewWithIdentifier:@"DefaultCell" owner:self];
    }
    cellView.episode = episode;
    
    NSString* title = [NSString stringWithFormat:@"%@", episode.title];

    [cellView.textField setStringValue:title];
    [cellView.imageView setImage:episode.podcast.bestPodcastArtAvailable];
    
    NSString* postDate = episode.postDate ? [NSString stringWithFormat:@"%@ • ", episode.postDate] : @"";
    NSString* timeRemaing = episode.timeRemaing ? episode.timeRemaing : @"";
    NSString* remaining = [episode.hasBegunPlaying isEqualToNumber:@YES] && timeRemaing.length>0 ? @" Remaining" : @"";
    
    NSString* timeRemainingString = [NSString stringWithFormat:@"%@%@%@", postDate, timeRemaing, remaining];
    [cellView.timeRemainingTextField setStringValue:timeRemainingString];
    return cellView;
}

- (IBAction)infoButtonPressed:(id)sender {
    OvercastEpisode* episode = [self.arrayController arrangeObjects:_episodeArray][[self.tableView rowForView:sender]];
    [episode openPermalink];
    
//    [self.navigationViewContoller navigateToViewControllerWithIdentifier:@"EpisodeInfoView"
//                                                    inStoryboardWithName:@"Main"];
}
- (IBAction)deleteButtonPressed:(NSButton *)sender {
    OvercastEpisode* episode = [self.arrayController arrangeObjects:_episodeArray][[self.tableView rowForView:sender]];
    [_appDelegate deleteEpisodeWithID:episode.uniqueID];
}

-(void) setCellFetchRequestWithPredicate:(NSString*) predicate sortDescripter:(NSString*) sortDescipter isAccending:(BOOL) accending
{
    self.cellFetchRequest = [self getCellFetchRequestWithPredicate:predicate sortDescripter:sortDescipter isAccending:accending];
}

-(NSFetchRequest*) getCellFetchRequestWithPredicate:(NSString*) predicate sortDescripter:(NSString*) sortDescipter isAccending:(BOOL) accending
{
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"OvercastEpisode"];
    request.predicate = [NSPredicate predicateWithFormat:predicate];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortDescipter
                                                              ascending:accending
                                                               selector:@selector(localizedStandardCompare:)]];
    return request;
}

-(void)setCellFetchRequest:(NSFetchRequest *)cellFetchRequest
{
    _cellFetchRequest = cellFetchRequest;
    [self loadEpisodes];
}

- (void)myBoundsChangeNotificationHandler:(NSNotification *)aNotification
{
    
}

- (IBAction)backButtonPressed:(NSButton *)sender {
    [self.navigationViewContoller navigateBack];
}

- (IBAction)refreshButtonPressed:(id)sender {
    [_appDelegate sendRequestWithURLString:OVERCAST_REQUEST_MAIN_PAGE];
}

-(void)wasNavigatedTo
{
    if(self.isFirstControllerInStack)
    {
        self.backButton.enabled = NO;
        self.backButton.animator.alphaValue = 0;
    }
    else
    {
        self.backButton.enabled = YES;
        self.backButton.animator.alphaValue = 1;
    }
}

@end
