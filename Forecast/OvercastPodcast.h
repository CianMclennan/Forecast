//
//  OvercastPodcast.h
//  
//
//  Created by Cian McLennan on 06/02/2016.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OvercastEpisode;

NS_ASSUME_NONNULL_BEGIN

@interface OvercastPodcast : NSManagedObject


@property (nonatomic, readonly) NSImage* bestPodcastArtAvailable;

+(OvercastPodcast*) podcastWithPodcastInfo:(NSDictionary*) podcastDictionary inManagedObjectContext: (NSManagedObjectContext*) context;
+(NSArray*) listOfPodcastsWithEpisodeInfoArray:(NSArray*) podcastInfoArray inManagedObjectContext: (NSManagedObjectContext*) context;

//-(void) updateWithPodcastInfo:(NSDictionary*) podcastDictionary inManagedObjectContext: (NSManagedObjectContext*) context shouldOverwrite:(BOOL) overwrite;

-(void) updatePodcastWithFeedURL:(NSString*) feedURL;

@end

NS_ASSUME_NONNULL_END

#import "OvercastPodcast+CoreDataProperties.h"
