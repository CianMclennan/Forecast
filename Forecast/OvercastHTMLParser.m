//
//  OvercastHTMLParser.m
//  Overcast
//
//  Created by Cian McLennan on 03/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "OvercastHTMLParser.h"
#import <HTMLReader/HTMLReader.h>
#import "NSString+Formatting.h"
#import "PodcastEpisodeAttributeList.h"

@implementation OvercastHTMLParser

#pragma mark - Single episode page
+(NSDictionary*) episodeDictionaryWithHTMLString:(NSString*) htmlString
{
    HTMLDocument *doc = [HTMLDocument documentWithString:htmlString];
    
    NSMutableDictionary * episode = [[NSMutableDictionary alloc] init];
    
    // audioplayer element
    HTMLElement * element = [[doc nodesMatchingSelector:@"#audioplayer"] firstObject];
    
    NSString* episodeShareURL = [element objectForKeyedSubscript:@"data-share-url"];
    [episode setObject:episodeShareURL
               forKey:EPISODE_OVERCAST_URL];
    
    
    NSString* episodeID = [episodeShareURL substringFromIndex:[@"https://overcast.fm/" length]];
    [episode setObject:episodeID
               forKey:EPISODE_ID];
    
    [episode setObject:[element objectForKeyedSubscript:@"data-item-id"]
               forKey:EPISODE_DATA_ITEM];
    
    [episode setObject:[element objectForKeyedSubscript:@"data-start-time"]
               forKey:EPISODE_START_TIME];
    
    BOOL isLoggedIn = [[element objectForKeyedSubscript:@"data-logged-in"] integerValue] == 1;
    [episode setObject:[NSString stringWithFormat:@"%@", (isLoggedIn ? @"true" : @"false")]
               forKey:EPISODE_IS_LOGGED_IN];
    
    NSString* syncVersion = [element objectForKeyedSubscript:@"data-sync-version"];
    [episode setObject:syncVersion
               forKey:EPISODE_SYNC_VERSION];
    
    element = [[doc nodesMatchingSelector:@"#audioplayer source"] firstObject];
    [episode setObject:[element objectForKeyedSubscript:@"src"]
               forKey:EPISODE_AUDIO_FILE_URL];
    
    // Podcast Permalink
    NSArray* linkArray = [doc nodesMatchingSelector:@"a"];
    for (HTMLNode* link in linkArray) {
        if ([link.textContent isEqualToString:@"Permalink"]) {
            element = (HTMLElement*)link;
            [episode setObject:[element objectForKeyedSubscript:@"href"]
                       forKey:EPISODE_PERMALINK_URL];
            break;
        }
    }
    
    // podcast image element
    element = [[doc nodesMatchingSelector:@".fullart"] firstObject];
    [episode setObject:[element objectForKeyedSubscript:@"src"]
               forKey:PODCAST_IMAGE_URL];
    
    // Episode title element
    HTMLNode* node = [[doc nodesMatchingSelector:@".title"] firstObject];
    [episode setObject:[node textContent]
               forKey:EPISODE_TITLE];
    
    // Podcast Title element
    NSUInteger elementID = isLoggedIn ? 1 : 0;
    node = [[doc nodesMatchingSelector:@".ocbutton"] objectAtIndex:elementID];
    [episode setObject:[node textContent]
               forKey:EPISODE_TITLE];
    
    //"#seekForwardValue text"
    node = [[doc nodesMatchingSelector:@"#seekforwardbutton text"] firstObject];
    [episode setObject:[node textContent]
               forKey:EPISODE_SEEK_FORWARD_VALUE];
    
    
    //"#seekBackwardValue text"
    node = [[doc nodesMatchingSelector:@"#seekbackbutton text"] firstObject];
    [episode setObject:[node textContent]
               forKey:EPISODE_SEEK_BACKWARD_VALUE];
    
    return episode;
}

#pragma mark - Episodes from main page
+(NSArray*) episodeInfoListWithHTMLSting:(NSString*) htmlString
{
    HTMLDocument *doc = [HTMLDocument documentWithString:htmlString];
    NSMutableArray* episodeList = [[NSMutableArray alloc] init];
    
    NSArray* episodeHTMLCells = [doc nodesMatchingSelector:@".episodecell"];
    
    NSUInteger episodeOrder = 0;
    for (HTMLElement* episodeCell in episodeHTMLCells) {
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        
        NSString* episodeID = [[episodeCell objectForKeyedSubscript:@"href"] substringFromIndex:1];
        
        [dict setObject:episodeID
                forKey:EPISODE_ID];
        
        NSString* href = [NSString stringWithFormat:@"https://overcast.fm/%@", episodeID];
        [dict setObject:href
                forKey:EPISODE_OVERCAST_URL];
        
        HTMLElement* imageElement = [[episodeCell nodesMatchingSelector:@"img"] firstObject];
        [dict setObject:[imageElement objectForKeyedSubscript:@"src"]
                forKey:PODCAST_THUMBNAIL_URL];
        
        NSArray* titleArray = [episodeCell nodesMatchingSelector:@".titlestack div"];
        
        NSString* podcastTitle = [titleArray[0] textContent];
        NSString* episodeTitle = [titleArray[1] textContent];
        NSString* timeRemainingString = [[titleArray[2] textContent] cleanString];
        NSDictionary* parsedTimeRemaining = [self parseTimeRemainingString:timeRemainingString];
        
        [dict addEntriesFromDictionary:parsedTimeRemaining];
        
        [dict setObject:podcastTitle
                forKey:PODCAST_TITLE];
        [dict setObject:episodeTitle
                forKey:EPISODE_TITLE];
        [dict setObject:@YES
                forKey:EPISODE_IS_IN_LIBRARY];
        [dict setObject:[NSString stringWithFormat:@"%ld", episodeOrder++]
                 forKey:EPISODE_ORDER_NUMBER];
        
        [episodeList addObject:dict];
    }
    
    return [episodeList copy];
}

+(NSDictionary *)parseTimeRemainingString:(NSString*)timeRemainingString
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSString* string = [timeRemainingString cleanString];
    NSRange range = [string rangeOfString:@" • "];
    dict[EPISODE_POST_DATE] = [string substringToIndex:range.location];
    NSUInteger start = range.location + 3;
    string = [string substringFromIndex:start];
    dict[EPISODE_HAS_BEGUN] = [string containsString:@"remaining"] ? @"YES" : @"NO";
    
    range = [string rangeOfString:@" "];
    
    string = range.length != 0 ? [string substringToIndex:range.location] : string;

    dict[EPISODE_TIME_REMAINING] = string;
    
    
    return [dict copy];
}

#pragma mark - Podcasts from main page
+(NSArray*) podcastInfoListWithHTMLSting:(NSString*) htmlString
{
    HTMLDocument *doc = [HTMLDocument documentWithString:htmlString];
    NSMutableArray* podcastList = [[NSMutableArray alloc] init];
    
    NSArray* podcastHTMLCells = [doc nodesMatchingSelector:@".feedcell"];
    
    for (HTMLElement* podcastCell in podcastHTMLCells) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        
        NSString* href = [podcastCell objectForKeyedSubscript:@"href"];
        href = [NSString stringWithFormat:@"https://overcast.fm%@", href];
        [dict setObject:href
                forKey:PODCAST_OVERCAST_URL];
        HTMLElement* imageElement = [[podcastCell nodesMatchingSelector:@"img"] firstObject];
        [dict setObject:[imageElement objectForKeyedSubscript:@"src"]
                forKey:PODCAST_THUMBNAIL_URL];
        HTMLNode* titleNode = [[podcastCell nodesMatchingSelector:@".title"] firstObject];
        [dict setObject:[titleNode textContent]
                forKey:PODCAST_TITLE];
        
        [podcastList addObject:dict];
    }
    
    return [podcastList copy];
}

#pragma mark - Full Episode list for a podcast
+(NSArray*) episodeInfoListWithAllEpisodesInPodcastHTMLSting:(NSString*) htmlString
{
    HTMLDocument *doc = [HTMLDocument documentWithString:htmlString];
    NSMutableArray* episodeList = [[NSMutableArray alloc] init];
    
    NSArray* navlinks = [doc nodesMatchingSelector:@".navlink"];
    BOOL isLoggedIn = YES;
    for (HTMLElement* navlinkElement in navlinks) {
        if ([[navlinkElement objectForKeyedSubscript:@"href"] isEqualToString:@"/login"]) {
            isLoggedIn = NO;
            break;
        }
    }
    
    NSArray* episodeCurrentHTMLCells = [doc nodesMatchingSelector:@".usernewepisode"];
    NSArray* episodeNonCurrentHTMLCells = [doc nodesMatchingSelector:@".userdeletedepisode"];
    
    HTMLElement* imgElement = [[doc nodesMatchingSelector:@".fullart"] firstObject];
    NSString* imageURL = [imgElement objectForKeyedSubscript:@"src"];
    
    HTMLNode* podcastTitleNode = [[doc nodesMatchingSelector:@"h2.centertext"] firstObject];
    NSString* podcastTitle = [podcastTitleNode textContent];
    
    NSUInteger episodeOrder = 0;
    
    for (HTMLElement* episodeCell in episodeCurrentHTMLCells) {
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [episodeList addObject:dict];
        NSString* episodeID = [[episodeCell objectForKeyedSubscript:@"href"] substringFromIndex:1];
        [dict setObject:episodeID
                forKey:EPISODE_ID];
        
        HTMLNode* episodeTitleNode = [[episodeCell nodesMatchingSelector:@".title"] firstObject];
        [dict setObject:[episodeTitleNode textContent]
                forKey:EPISODE_TITLE];
        
        NSString* href = [NSString stringWithFormat:@"https://overcast.fm/%@", episodeID];
        [dict setObject:href
                forKey:EPISODE_OVERCAST_URL];
        
        [dict setObject:imageURL
                forKey:PODCAST_IMAGE_URL];
        
        [dict setObject:podcastTitle
                forKey:PODCAST_TITLE];
        
        [dict setObject:isLoggedIn ? @YES : @NO
                forKey:EPISODE_IS_IN_LIBRARY];
        [dict setObject:[NSString stringWithFormat:@"%ld", episodeOrder++]
                 forKey:EPISODE_ORDER_NUMBER];
    }
    for (HTMLElement* episodeCell in episodeNonCurrentHTMLCells) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [episodeList addObject:dict];
        NSString* episodeID = [[episodeCell objectForKeyedSubscript:@"href"] substringFromIndex:1];
        [dict setObject:episodeID
                forKey:EPISODE_ID];
        
        HTMLNode* episodeTitleNode = [[episodeCell nodesMatchingSelector:@".title"] firstObject];
        [dict setObject:[episodeTitleNode textContent]
                forKey:EPISODE_TITLE];
        
        NSString* href = [NSString stringWithFormat:@"https://overcast.fm/%@", episodeID];
        [dict setObject:href
                forKey:EPISODE_OVERCAST_URL];
        
        [dict setObject:imageURL
                forKey:PODCAST_IMAGE_URL];
        
        [dict setObject:podcastTitle
                forKey:PODCAST_TITLE];
        [dict setObject:@NO
                forKey:EPISODE_IS_IN_LIBRARY];
        [dict setObject:[NSString stringWithFormat:@"%ld", episodeOrder++]
                 forKey:EPISODE_ORDER_NUMBER];
    }
    
    return episodeList;
}

+(BOOL) checkIsHtmlStringLoginPage:(NSString*) potentialLoginPage
{
    HTMLDocument *doc = [HTMLDocument documentWithString:potentialLoginPage];
    return [doc nodesMatchingSelector:@".controller_main"].count;
}

+(enum OvercastPageType) typeOfPageWithHTMLString: (NSString*) htmlString
{
    HTMLDocument *doc = [HTMLDocument documentWithString:htmlString];
    if([doc nodesMatchingSelector:@".controller_main"].count > 0) {
        return OvercastLoginPage;
    }
    if([doc nodesMatchingSelector:@".ocseparatorbar"].count > 1) {
        return OvercastMainPage;
    }
    if([doc nodesMatchingSelector:@"#audioplayer"].count > 0) {
        return OvercastEpisodePlayerPage;
    }
    if([doc nodesMatchingSelector:@".userdeletedepisode"].count > 0
       || [doc nodesMatchingSelector:@".usernewepisode"].count > 0) {
        return OvercastPodcastListPage;
    }
    return OvercastUnknownPage;
}

+(BOOL) pageIsLoggedInWithHTMLString:(NSString*) htmlString
{
    HTMLDocument *doc = [HTMLDocument documentWithString:htmlString];
    
    NSArray* navlinks = [doc nodesMatchingSelector:@".navlink"];
    BOOL isLoggedIn = YES;
    for (HTMLElement* navlinkElement in navlinks) {
        if ([[navlinkElement objectForKeyedSubscript:@"href"] isEqualToString:@"/login"]) {
            isLoggedIn = NO;
            break;
        }
    }
    return isLoggedIn;
}

@end
