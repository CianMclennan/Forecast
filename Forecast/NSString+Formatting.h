//
//  NSString+Formatting.h
//  Overcast
//
//  Created by Cian McLennan on 03/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Formatting)

-(NSString*)stringByTrimmingLeadingWhitespace;
-(NSString*) cleanString;

@end
