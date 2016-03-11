//
//  OvercastPodcast+CoreDataProperties.h
//  
//
//  Created by Cian McLennan on 05/03/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "OvercastPodcast.h"

NS_ASSUME_NONNULL_BEGIN

@interface OvercastPodcast (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSString *informaiton;
@property (nullable, nonatomic, retain) NSString *lastModified;
@property (nullable, nonatomic, retain) NSString *overcastURL;
@property (nullable, nonatomic, retain) NSNumber *shouldDisplay;
@property (nullable, nonatomic, retain) NSData *thumbnail;
@property (nullable, nonatomic, retain) NSString *thumbnailURL;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *uniqueID;
@property (nullable, nonatomic, retain) NSNumber *isInLibrary;
@property (nullable, nonatomic, retain) NSSet<OvercastEpisode *> *episodes;

@end

@interface OvercastPodcast (CoreDataGeneratedAccessors)

- (void)addEpisodesObject:(OvercastEpisode *)value;
- (void)removeEpisodesObject:(OvercastEpisode *)value;
- (void)addEpisodes:(NSSet<OvercastEpisode *> *)values;
- (void)removeEpisodes:(NSSet<OvercastEpisode *> *)values;

@end

NS_ASSUME_NONNULL_END
