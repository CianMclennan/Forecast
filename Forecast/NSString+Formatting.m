//
//  NSString+Formatting.m
//  Overcast
//
//  Created by Cian McLennan on 03/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "NSString+Formatting.h"
#import "PodcastEpisodeAttributeList.h"

@implementation NSString (Formatting)

-(NSString*)stringByTrimmingLeadingWhitespace {
    NSInteger i = 0;
    
    while ((i < [self length])
           && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    
    return [self substringFromIndex:i];
}

-(NSString*) stringByRemovingNewLines
{
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}
-(NSString*) cleanString
{
    NSString* string = [self stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
//@"• "

@end
