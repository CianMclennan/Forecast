//
//  OvercastEpisode.m
//  
//
//  Created by Cian McLennan on 06/02/2016.
//
//

#import "OvercastEpisode.h"
#import "OvercastPodcast.h"
#import <CoreData/CoreData.h>
#import "PodcastEpisodeAttributeList.h"
#import "AppDelegate.h"
#import <AppKit/AppKit.h>

@implementation OvercastEpisode
{
    id<NSObject> _permalinkNotification;
}

+(OvercastEpisode*) episodeWithEpisodeInfo:(NSDictionary*) episodeDictionary inManagedObjectContext: (NSManagedObjectContext*) context
{
    OvercastEpisode* episode = nil;
    
    NSString* episodeID = [episodeDictionary objectForKey:EPISODE_ID];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"OvercastEpisode"];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", episodeID];
    
    NSError* error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1) {
        // TODO: Handle Error
    } else if([matches count]) {
        episode = [matches firstObject];
        [episode updateWithEpisodeInfo:episodeDictionary inManagedObjectContext:context shouldOverwrite:YES];
    } else {
        episode = [NSEntityDescription insertNewObjectForEntityForName:@"OvercastEpisode"
                                                inManagedObjectContext:context];
        
        episode.podcast = [OvercastPodcast podcastWithPodcastInfo:episodeDictionary inManagedObjectContext:context];
        
        episode.audioFileURL         = [episodeDictionary objectForKey:EPISODE_AUDIO_FILE_URL];
        episode.podcast.imageURL     = [episodeDictionary objectForKey:PODCAST_IMAGE_URL];
        episode.overcastURL          = [episodeDictionary objectForKey:EPISODE_OVERCAST_URL];
        episode.permalinkURL         = [episodeDictionary objectForKey:EPISODE_PERMALINK_URL];
        episode.seekBackwardValue    = [episodeDictionary objectForKey:EPISODE_SEEK_BACKWARD_VALUE];
        episode.seekForwardValue     = [episodeDictionary objectForKey:EPISODE_SEEK_FORWARD_VALUE];
        episode.startTime            = [episodeDictionary objectForKey:EPISODE_START_TIME];
        episode.syncVersion          = [episodeDictionary objectForKey:EPISODE_SYNC_VERSION];
        episode.podcast.thumbnailURL = [episodeDictionary objectForKey:PODCAST_THUMBNAIL_URL];
        episode.title                = [episodeDictionary objectForKey:EPISODE_TITLE];
        episode.uniqueID             = [episodeDictionary objectForKey:EPISODE_ID];
        episode.itemID               = [episodeDictionary objectForKey:EPISODE_DATA_ITEM];
        episode.isInLibrary          = [episodeDictionary objectForKey:EPISODE_IS_IN_LIBRARY];
        episode.orderNumber          = [episodeDictionary objectForKey:EPISODE_ORDER_NUMBER];
        episode.timeRemaing          = [episodeDictionary objectForKey:EPISODE_TIME_REMAINING];
        episode.postDate             = [episodeDictionary objectForKey:EPISODE_POST_DATE];
        episode.shouldDisplay        = [[episodeDictionary objectForKey:EPISODE_DATA_ITEM]isEqualToString: @"NO"] ? @NO : @YES;
        episode.hasBegunPlaying      = [[episodeDictionary objectForKey:EPISODE_HAS_BEGUN]isEqualToString: @"NO"] ? @NO : @YES;
    }
    return episode;
}
-(void) updateWithEpisodeInfo:(NSDictionary*) episodeDictionary inManagedObjectContext: (NSManagedObjectContext*) context shouldOverwrite:(BOOL) overwrite
{
    // don't ever overwrite these valuse
    self.podcast.imageURL     = [self updatedValue:self.podcast.imageURL     withValue:episodeDictionary[PODCAST_IMAGE_URL]      overwrite:NO];
    self.overcastURL          = [self updatedValue:self.overcastURL          withValue:episodeDictionary[EPISODE_OVERCAST_URL]   overwrite:NO];
    self.audioFileURL         = [self updatedValue:self.audioFileURL         withValue:episodeDictionary[EPISODE_AUDIO_FILE_URL] overwrite:NO];
    self.permalinkURL         = [self updatedValue:self.permalinkURL         withValue:episodeDictionary[EPISODE_PERMALINK_URL]  overwrite:NO];
    self.title                = [self updatedValue:self.title                withValue:episodeDictionary[EPISODE_TITLE]          overwrite:NO];
    self.uniqueID             = [self updatedValue:self.uniqueID             withValue:episodeDictionary[EPISODE_ID]             overwrite:NO];
    self.itemID               = [self updatedValue:self.itemID               withValue:episodeDictionary[EPISODE_DATA_ITEM]      overwrite:NO];
    self.podcast.thumbnailURL = [self updatedValue:self.podcast.thumbnailURL withValue:episodeDictionary[EPISODE_DATA_ITEM]      overwrite:NO];
    
    // overwrite these valuse if asked to
    self.seekBackwardValue = [self updatedValue:self.seekBackwardValue withValue:episodeDictionary[EPISODE_SEEK_BACKWARD_VALUE] overwrite:overwrite];
    self.seekForwardValue  = [self updatedValue:self.seekForwardValue  withValue:episodeDictionary[EPISODE_SEEK_FORWARD_VALUE]  overwrite:overwrite];
    self.startTime         = [self updatedValue:self.startTime         withValue:episodeDictionary[EPISODE_START_TIME]          overwrite:overwrite];
    self.syncVersion       = [self updatedValue:self.syncVersion       withValue:episodeDictionary[EPISODE_SYNC_VERSION]        overwrite:overwrite];
    self.isInLibrary       = [self updatedValue:self.isInLibrary       withValue:episodeDictionary[EPISODE_IS_IN_LIBRARY]       overwrite:overwrite];
    self.timeRemaing       = [self updatedValue:self.timeRemaing       withValue:episodeDictionary[EPISODE_TIME_REMAINING]      overwrite:overwrite];
    self.postDate          = [self updatedValue:self.postDate          withValue:episodeDictionary[EPISODE_POST_DATE]           overwrite:overwrite];
//    self.orderNumber        = self.orderNumber       && !overwrite   ? self.orderNumber      : [episodeDictionary objectForKey:EPISODE_ORDER_NUMBER];
}

-(id) updatedValue:(id) value withValue:( id _Nullable ) newValue overwrite:(BOOL) overwrite
{
    if ((value && !overwrite) || !newValue)
        return value;
    return newValue;
}

+(NSArray*) listOfEpisodesWithEpisodeInfoArray:(NSArray*) episodeInfoArray inManagedObjectContext: (NSManagedObjectContext*) context
{
    return [[self class] listOfEpisodesWithEpisodeInfoArray:episodeInfoArray forSpecificPodcast:nil inManagedObjectContext:context];
}

+(NSArray*) listOfEpisodesWithEpisodeInfoArray:(NSArray*) episodeInfoArray forSpecificPodcast:(nullable NSString*) podcastName inManagedObjectContext: (NSManagedObjectContext*) context
{
    NSMutableArray* episodeArray = [[NSMutableArray alloc] init];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"OvercastEpisode"];
    if (podcastName)
    {
        NSString* predicateString = [NSString stringWithFormat:@"podcast.title == \"%@\"", podcastName];
        request.predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    NSError* error;
    NSArray* results = [context executeFetchRequest:request error:&error];
    NSMutableArray* episodeStack = [NSMutableArray arrayWithArray:results];
    if (!results) {
        NSLog(@"%@", error);
    }
    else
    {
        for (NSDictionary* dict in episodeInfoArray) {
            
            OvercastEpisode* episode = [OvercastEpisode episodeWithEpisodeInfo:dict inManagedObjectContext:context];
            [episodeArray addObject:episode];
            for (NSUInteger i = 0; i < episodeStack.count; i++) {
                OvercastEpisode* tempEpisode = [episodeStack objectAtIndex:i];
                if([tempEpisode.uniqueID isEqualToString:episode.uniqueID])
                {
                    [episodeStack removeObjectIdenticalTo:tempEpisode];
                    --i;
                }
            }
        }
        for (OvercastEpisode* episode in episodeStack) {
            episode.isInLibrary = NO;
            [episodeArray removeObjectIdenticalTo:episode];
        }
    }
    
    return [episodeArray copy];
}

-(NSURL *)deletePodcastURL
{
    if (self.itemID)
    {
        NSString* urlString = [NSString stringWithFormat:@"https://overcast.fm/podcasts/delete_item/%@", self.itemID];
        return [NSURL URLWithString:urlString];
    }
    return nil;
}

-(NSURLRequest *)getUpdateRequestWithProgress:(NSUInteger) progress
{
    NSString* urlString = [NSString stringWithFormat:@"https://overcast.fm/podcasts/set_progress/%@", self.itemID];
    NSURL *aUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"p=%ld&speed=0&v=%@", progress, self.syncVersion];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

-(void)openPermalink;
{
    if(self.permalinkURL)
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: self.permalinkURL]];
    else{
        _permalinkNotification = [[NSNotificationCenter defaultCenter] addObserverForName:EPISODE_INFO_LOADED_NOTIFICATION
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          OvercastEpisode* episode = note.userInfo[EPISODE_USER_INFO_KEY];
                                                          if ([episode.uniqueID isEqualToString:self.uniqueID]) {
                                                              [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: self.permalinkURL]];
                                                              [[NSNotificationCenter defaultCenter] removeObserver:_permalinkNotification];
                                                              _permalinkNotification = nil;
                                                          }
                                                      }];
        [[[NSApplication sharedApplication] delegate] sendRequestWithURLString:self.overcastURL];
    }
}

@end
