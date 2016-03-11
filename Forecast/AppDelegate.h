//
//  AppDelegate.h
//  Forecast
//
//  Created by Cian McLennan on 07/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MANAGED_OBJECT_CONTEXT_UPDATED_NOTIFICATION @"managedObjectContextUpdated"
#define REQUEST_SENT_NOTIFICATION                   @"requestSent"
#define REQUEST_RESPONSE_RECIVED_NOTIFICATION       @"requestResponseRecived"

#define INTERNET_CONNECTION_CHANGED_NOTIFICATION    @"InternetConnectionChangedNotification"
#define INTERNET_CONNECTION_STATUS                  @"InternetConnectionStatus"

#define SIGN_IN_STATE_CHANGED_NOTIFICATION          @"signInStateChanged"

#define OVERCAST_REQUEST_MAIN_PAGE                  @"https://overcast.fm/login"
#define EPISODE_INFO_LOADED_NOTIFICATION            @"episodeInfoLoaded"
#define EPISODE_USER_INFO_KEY                       @"episodeUserInfoKey"

#define SIGN_IN_TEXT   @"Sign in..."
#define SIGN_OUT_TEXT  @"Sign Out"
#define USER_ID        @"userID"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSMenuItem *signInOutMenuItem;

@property (readonly, strong, nonatomic, nonnull) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic, nonnull) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic, nonnull) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSUInteger timoutCount;

@property (nonatomic, readonly) BOOL online;

@property (nonatomic, nullable) NSString* currentPodcastID;

- (void) loadEpisodeWithEpisodeID: (nonnull NSString*) episodeID;
- (void) presentAuthenticationDialogWithErrorMessage:(nullable NSString*) errorMessage;
- (IBAction) userRequestedSignout:(nullable id)sender;

//Network Requests
-(void) sendRequestWithURLString:(nonnull NSString*)url;
-(void) parseHtmlString:(nonnull NSString*) htmlString;
-(void) deleteEpisodeWithID:(nonnull NSString*) episodeID;

@end

