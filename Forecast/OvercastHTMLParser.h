//
//  OvercastHTMLParser.h
//  Overcast
//
//  Created by Cian McLennan on 03/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

enum OvercastPageType
{
    OvercastMainPage,
    OvercastPodcastListPage,
    OvercastEpisodePlayerPage,
    OvercastLoginPage,
    OvercastUnknownPage
};

#import <Foundation/Foundation.h>

@interface OvercastHTMLParser : NSObject

+(NSDictionary*) episodeDictionaryWithHTMLString:(NSString*) htmlString;


+(NSArray*) episodeInfoListWithAllEpisodesInPodcastHTMLSting:(NSString*) htmlString;

+(NSArray*) episodeInfoListWithHTMLSting:(NSString*) htmlString;
+(NSArray*) podcastInfoListWithHTMLSting:(NSString*) htmlString;

+(BOOL) checkIsHtmlStringLoginPage:(NSString*) potentialLoginPage;

+(enum OvercastPageType) typeOfPageWithHTMLString: (NSString*) htmlString;
+(BOOL) pageIsLoggedInWithHTMLString:(NSString*) htmlString;

@end
