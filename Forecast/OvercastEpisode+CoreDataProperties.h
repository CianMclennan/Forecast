//
//  OvercastEpisode+CoreDataProperties.h
//  
//
//  Created by Cian McLennan on 22/02/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "OvercastEpisode.h"

NS_ASSUME_NONNULL_BEGIN

@interface OvercastEpisode (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *audioFileURL;
@property (nullable, nonatomic, retain) NSNumber *isInLibrary;
@property (nullable, nonatomic, retain) NSString *itemID;
@property (nullable, nonatomic, retain) NSString *orderNumber;
@property (nullable, nonatomic, retain) NSString *overcastURL;
@property (nullable, nonatomic, retain) NSString *permalinkURL;
@property (nullable, nonatomic, retain) NSString *seekBackwardValue;
@property (nullable, nonatomic, retain) NSString *seekForwardValue;
@property (nullable, nonatomic, retain) NSNumber *shouldDisplay;
@property (nullable, nonatomic, retain) NSString *startTime;
@property (nullable, nonatomic, retain) NSString *syncVersion;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *uniqueID;
@property (nullable, nonatomic, retain) NSString *timeRemaing;
@property (nullable, nonatomic, retain) NSNumber *hasBegunPlaying;
@property (nullable, nonatomic, retain) NSString *postDate;
@property (nullable, nonatomic, retain) OvercastPodcast *podcast;

@end

NS_ASSUME_NONNULL_END
