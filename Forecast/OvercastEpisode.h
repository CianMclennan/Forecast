//
//  OvercastEpisode.h
//  
//
//  Created by Cian McLennan on 06/02/2016.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OvercastPodcast;

NS_ASSUME_NONNULL_BEGIN

@interface OvercastEpisode : NSManagedObject

+(OvercastEpisode*) episodeWithEpisodeInfo:(NSDictionary*) episodeDictionary inManagedObjectContext: (NSManagedObjectContext*) context;

+(NSArray*) listOfEpisodesWithEpisodeInfoArray:(NSArray*) episodeInfoArray inManagedObjectContext: (NSManagedObjectContext*) context;
+(NSArray*) listOfEpisodesWithEpisodeInfoArray:(NSArray*) episodeInfoArray forSpecificPodcast:(nullable NSString*) podcastName inManagedObjectContext: (NSManagedObjectContext*) context;

-(void) updateWithEpisodeInfo:(NSDictionary*) episodeDictionary inManagedObjectContext: (NSManagedObjectContext*) context shouldOverwrite:(BOOL) overwrite;

-(NSURL *)deletePodcastURL;
-(NSURLRequest *)getUpdateRequestWithProgress:(NSUInteger) progress;

-(void)openPermalink;

@end

NS_ASSUME_NONNULL_END

#import "OvercastEpisode+CoreDataProperties.h"
