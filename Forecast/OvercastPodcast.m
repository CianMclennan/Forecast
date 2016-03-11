//
//  OvercastPodcast.m
//  
//
//  Created by Cian McLennan on 06/02/2016.
//
//

#import "OvercastPodcast.h"
#import "OvercastEpisode.h"
#import "PodcastEpisodeAttributeList.h"
#import <Cocoa/Cocoa.h>

@implementation OvercastPodcast

#pragma mark - single podcast with info
+(OvercastPodcast*) podcastWithPodcastInfo:(NSDictionary*) podcastDictionary inManagedObjectContext: (NSManagedObjectContext*) context
{
    OvercastPodcast* podcast = nil;
    
    NSString* podcastTitle = [podcastDictionary objectForKey:PODCAST_TITLE];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"OvercastPodcast"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", podcastTitle];
    
    NSError* error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1) {
        // TODO: Handle Error
    } else if([matches count]) {
        podcast = [matches firstObject];
        [podcast updateWithPodcastInfo:podcastDictionary inManagedObjectContext:context];
    } else {
        podcast = [NSEntityDescription insertNewObjectForEntityForName:@"OvercastPodcast"
                                                inManagedObjectContext:context];
        
        podcast.author          = [podcastDictionary objectForKey:PODCAST_AUTHOR];
        podcast.imageURL        = [podcastDictionary objectForKey:PODCAST_IMAGE_URL];
        podcast.informaiton     = [podcastDictionary objectForKey:PODCAST_DESCRIPTION];
        podcast.lastModified    = [podcastDictionary objectForKey:PODCAST_LAST_MODIFIED_TIME];
        podcast.thumbnailURL    = [podcastDictionary objectForKey:PODCAST_THUMBNAIL_URL];
        podcast.title           = [podcastDictionary objectForKey:PODCAST_TITLE];
        podcast.overcastURL     = [podcastDictionary objectForKey:PODCAST_OVERCAST_URL];
    }
    
    return podcast;
}

-(void) updateWithPodcastInfo:(NSDictionary*) podcastDictionary inManagedObjectContext: (NSManagedObjectContext*) context
{
    self.author         = [self updatedValue:self.author       withValue:podcastDictionary[PODCAST_AUTHOR]             overwrite:YES];
    self.imageURL       = [self updatedValue:self.imageURL     withValue:podcastDictionary[PODCAST_IMAGE_URL]          overwrite:YES];
    self.informaiton    = [self updatedValue:self.informaiton  withValue:podcastDictionary[PODCAST_DESCRIPTION]        overwrite:YES];
    self.lastModified   = [self updatedValue:self.lastModified withValue:podcastDictionary[PODCAST_LAST_MODIFIED_TIME] overwrite:YES];
    self.thumbnailURL   = [self updatedValue:self.thumbnailURL withValue:podcastDictionary[PODCAST_THUMBNAIL_URL]      overwrite:YES];
    self.overcastURL    = [self updatedValue:self.overcastURL  withValue:podcastDictionary[PODCAST_OVERCAST_URL]       overwrite:YES];
}

-(id) updatedValue:(id) value withValue:( id _Nullable ) newValue overwrite:(BOOL) overwrite
{
    if ((value && !overwrite) || !newValue)
        return value;
    return newValue;
}

#pragma mark - List of podcasts
+(NSArray*) listOfPodcastsWithEpisodeInfoArray:(NSArray*) podcastInfoArray inManagedObjectContext: (NSManagedObjectContext*) context
{
    NSMutableArray* podcastArray = [[NSMutableArray alloc] init];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"OvercastPodcast"];
    NSError* error;
    NSArray* results = [context executeFetchRequest:request error:&error];
    NSMutableArray* podcastStack = [NSMutableArray arrayWithArray:results];
    if (!results) {
        NSLog(@"%@", error);
    }
    else
    {
        for (NSDictionary* dict in podcastInfoArray) {
            
            OvercastPodcast* podcast = [OvercastPodcast podcastWithPodcastInfo:dict inManagedObjectContext:context];
            [podcastArray addObject:podcast];
            for (NSUInteger i = 0; i < podcastStack.count; i++) {
                OvercastPodcast* tempPodcast = [podcastStack objectAtIndex:i];
                if([tempPodcast.uniqueID isEqualToString:podcast.uniqueID])
                {
                    [podcastStack removeObjectIdenticalTo:tempPodcast];
                    --i;
                }
            }
        }
        for (OvercastPodcast* podcast in podcastStack) {
            podcast.isInLibrary = NO;
            [podcastArray removeObjectIdenticalTo:podcast];
        }
    }
    return [podcastArray copy];
}

-(NSImage*) bestPodcastArtAvailable
{
    NSImage* image;
    if (self.image) {
        image = [[NSImage alloc] initWithData:self.image];
        return image;
    }
    else if (self.imageURL)
    {
        NSURL* url = [NSURL URLWithString:self.imageURL];
        image = [[NSImage alloc] initWithContentsOfURL:url];
        self.image = [image TIFFRepresentation];
        return image;
    }
    else if (self.thumbnail)
    {
        image = [[NSImage alloc] initWithData:self.thumbnail];
        return image;
    }
    else if(self.thumbnailURL)
    {
        NSURL* url = [NSURL URLWithString:self.thumbnailURL];
        image = [[NSImage alloc] initWithContentsOfURL:url];
        self.thumbnail = [image TIFFRepresentation];
        return image;
    }
    return nil;
}

-(void)updatePodcastWithFeedURL:(NSString *)feedURL
{
    NSAssert(false, @"Unimplemented");
}

@end
