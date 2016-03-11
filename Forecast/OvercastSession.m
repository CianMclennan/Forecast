//
//  OvercastSession.m
//  Overcast
//
//  Created by Cian McLennan on 03/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OvercastSession.h"
#import "OvercastHTMLParser.h"
#import "AppDelegate.h"

@interface OvercastSession () <NSURLSessionDelegate>

@property (nonatomic) NSURLSession* session;

@end

@implementation OvercastSession

+(OvercastSession*) sharedSession {
    static OvercastSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [[self alloc] init];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        session.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:session delegateQueue:nil];
    });
    return session;
}

-(void) sendRequestToUrlString:(NSString*) urlString withCompletionHandler: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    NSURL* url = [NSURL URLWithString:urlString];
    [self sendRequestToUrl:url withCompletionHandler:handler];
}
-(void) sendRequestToUrl:(NSURL*) url withCompletionHandler: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self sendRequest:request withCompletionHandler:handler];
}

-(void) sendRequest:(NSURLRequest*)request withCompletionHandler: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    if (!handler) {
        handler = ^(NSData *data, NSURLResponse *response, NSError *error){};
    }
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:handler];
    [task resume];
}

-(void) loginWithUsername:(NSString*) username andPassword:(NSString*) password
{
    AppDelegate* appDelegate = [[NSApplication sharedApplication] delegate];
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:USER_ID];
    NSString* urlString = [NSString stringWithFormat:@"https://overcast.fm/login"];
    NSURL *aUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"email=%@&password=%@", username, password];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_SENT_NOTIFICATION
                                                        object:nil];
    [self sendRequest:request withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSString* htmlString;
        @try {
            htmlString = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
        }
        @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [appDelegate presentAuthenticationDialogWithErrorMessage:@"Could not connect to http://overcast.fm"];
                [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_RESPONSE_RECIVED_NOTIFICATION
                                                                    object:nil];
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (htmlString.length >0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_RESPONSE_RECIVED_NOTIFICATION
                                                                    object:nil];
                if ([OvercastHTMLParser checkIsHtmlStringLoginPage:htmlString] )
                {
                    [appDelegate presentAuthenticationDialogWithErrorMessage:@"Could not log in with given credentials."];
                }
                else{
                    [appDelegate parseHtmlString:htmlString];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SIGN_IN_STATE_CHANGED_NOTIFICATION
                                                                        object:self];
                }
            }
            else{
                [self loginWithUsername:username andPassword:password];
            }
        });
    }];
}

-(NSUInteger) clearCookies
{
    NSUInteger numberOfCookies = 0;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        numberOfCookies++;
        [cookieStorage deleteCookie:each];
    }
    return numberOfCookies;
}

-(BOOL) isLoggedIn
{
    return [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies.count > 0;
}

@end
