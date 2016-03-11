//
//  OvercastSession.h
//  Overcast
//
//  Created by Cian McLennan on 03/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OvercastSession : NSObject

+(OvercastSession*) sharedSession;

-(void) sendRequestToUrlString:(NSString*) urlString withCompletionHandler: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;
-(void) sendRequestToUrl:(NSURL*) url withCompletionHandler: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;
-(void) sendRequest:(NSURLRequest*)request withCompletionHandler: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

-(NSUInteger) clearCookies;
-(void) loginWithUsername:(NSString*) username andPassword:(NSString*) password;
-(BOOL) isLoggedIn;
@end
