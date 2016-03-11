//
//  AppDelegate.m
//  Forecast
//
//  Created by Cian McLennan on 07/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "AppDelegate.h"
#import "OvercastEpisodePlayer.h"
#import "OvercastHTMLParser.h"
#import "OvercastSession.h"
#import "OvercastPodcast.h"
#import "PodcastEpisodeAttributeList.h"
#import "Reachability.h"
#import "AuthenticationWindowVC.h"

#define CURRENT_PODCAST_KEY @"currentPodcast"

@interface AppDelegate ()

- (IBAction)saveAction:(id)sender;

@end

@implementation AppDelegate
{
    Reachability* _connection;
}

#pragma mark - Default AppDelegate Methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.timoutCount = 0;
    _connection = [Reachability reachabilityForInternetConnection];
    [_connection startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SIGN_IN_STATE_CHANGED_NOTIFICATION object:self];
    [self updateOfflineOnline:_connection];
    if ([[OvercastSession sharedSession] isLoggedIn])
    {
        if (self.currentPodcastID.length > 0) {
            [self loadEpisodeWithEpisodeID:self.currentPodcastID];
        }
#ifndef DEBUG
        [self sendRequestWithURLString:OVERCAST_REQUEST_MAIN_PAGE];
#endif
    }
    // Handle Spacebar toggle play pause.
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask
//                                          handler:^NSEvent * (NSEvent * theEvent) {
//                                              if (theEvent.keyCode == 49) {
//                                                  [[OvercastEpisodePlayer sharedPlayer] togglePlayPause];
//                                                  theEvent = nil;
//                                              }
//                                              return theEvent;
//                                          }];
    [[NSNotificationCenter defaultCenter] addObserverForName:PLAYER_DELETE_REQUEST_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      OvercastEpisodePlayer* player = note.userInfo[PLAYER_KEY];
                                                      [self deleteEpisodeWithID:player.episode.uniqueID];
                                                  }];
    
    
}
-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    [[[[NSApplication sharedApplication] windows] firstObject] makeKeyAndOrderFront:self];
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.managedObjectContext commitEditing];
}


#pragma mark - Persistence Methods
-(NSString *)currentPodcastID
{
#ifdef DEBUG
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_DEBUG", CURRENT_PODCAST_KEY]];
#else
    return [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_PODCAST_KEY];
#endif
}
-(void)setCurrentPodcastID:(NSString *)currentPodcastID
{
#ifdef DEBUG
    [[NSUserDefaults standardUserDefaults] setObject:currentPodcastID forKey:[NSString stringWithFormat:@"%@_DEBUG", CURRENT_PODCAST_KEY]];
#else
    [[NSUserDefaults standardUserDefaults] setObject:currentPodcastID forKey:CURRENT_PODCAST_KEY];
#endif
}

#pragma mark - Episode Moddel Handlers
-(void) loadEpisodeWithEpisodeID: (NSString*) episodeID
{
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"OvercastEpisode"];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", episodeID];
    NSError *error;
    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (!results || results.count > 1) {
        NSLog(@"%@", error);
    }
    else if (results.count != 0){
        OvercastEpisode* episode = [results firstObject];
        if (episode.isInLibrary && self.online) {
            [[OvercastEpisodePlayer sharedPlayer] loadPodcastFromEpisode:episode playWhenReady:NO];
        }
    }
}

#pragma mark - Authentication Methods

-(void)presentAuthenticationDialogWithErrorMessage:(nullable NSString*) errorMessage
{
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthenticationWindowVC* myController = [storyBoard instantiateControllerWithIdentifier:@"AuthenticationWindow"];
    myController.errorMessage = errorMessage;
    
    NSWindow* window = [[[NSApplication sharedApplication] windows] firstObject];
    [window.contentViewController presentViewControllerAsSheet:myController];
}

- (IBAction)userRequestedSignout:(id)sender {
    NSMenuItem* menuItem = sender;
    menuItem.title = [menuItem.title isEqualToString:SIGN_OUT_TEXT] ? SIGN_IN_TEXT : SIGN_OUT_TEXT;
    if([menuItem.title isEqualToString:SIGN_IN_TEXT])
    {
        [[OvercastSession sharedSession] clearCookies];
        NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"OvercastEpisode"];
        NSError *error;
        NSArray* results = [_managedObjectContext executeFetchRequest:request error:&error];
        if (!results) {
            NSLog(@"%@", error);
        }
        else{
            for (OvercastEpisode* episode in results) {
                episode.isInLibrary = @NO;
            }
            [self saveAction:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:MANAGED_OBJECT_CONTEXT_UPDATED_NOTIFICATION
                                                            object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:SIGN_IN_STATE_CHANGED_NOTIFICATION
                                                            object:self];
    }
    else
    {
        [self presentAuthenticationDialogWithErrorMessage:nil];
    }
}

#pragma mark - Reachability

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateOfflineOnline:curReach];
}

- (void) updateOfflineOnline:(Reachability*) reachability
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INTERNET_CONNECTION_CHANGED_NOTIFICATION
                                                        object:self
                                                      userInfo:@{INTERNET_CONNECTION_STATUS: reachability}];
}
-(BOOL)online
{
    return [_connection currentReachabilityStatus] != NotReachable;
}

#pragma mark - Defaults
+(void) clearDefaults
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}
#pragma mark - Network Requests

-(void) requestSent
{
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_SENT_NOTIFICATION
                                                        object:nil];
}
-(void) requestResponseRecived
{
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_RESPONSE_RECIVED_NOTIFICATION
                                                        object:nil];
}

#pragma mark - methods for interfacing with the web server
-(void) sendRequestWithURLString:(NSString*)url
{
    
    if (self.timoutCount > 10) {
        [self requestResponseRecived];
        self.timoutCount = 0;
        return;
    }
    [self requestSent];
    [[OvercastSession sharedSession] sendRequestToUrlString:url
                                      withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
     {
         NSString* htmlString = data ? [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding] : @"";
         dispatch_async(dispatch_get_main_queue(), ^{
             if (htmlString.length > 0)
             {
                 self.timoutCount = 0;
                 [self parseHtmlString:htmlString];
             }
             else
             {
                 self.timoutCount++;
                 [self sendRequestWithURLString:url];
             }
         });
     }];
}

-(void) parseHtmlString:(NSString*) htmlString
{
    switch ([OvercastHTMLParser typeOfPageWithHTMLString:htmlString]) {
        case OvercastLoginPage:
            self.signInOutMenuItem.title = SIGN_IN_TEXT;
            [self presentAuthenticationDialogWithErrorMessage:nil];
            [self requestResponseRecived];
            break;
        case OvercastMainPage:
            self.signInOutMenuItem.title = SIGN_OUT_TEXT;
            [self handleMainPageHTMLString:htmlString];
            break;
        case OvercastPodcastListPage:
            [self handlePodcastListPageHTMLString:htmlString];
            break;
        case OvercastEpisodePlayerPage:
            [self handleEpisodePlayerPage:htmlString];
            break;
        default:
            NSLog(@"Unknown Page Type");
            break;
    }
}

-(void) handleMainPageHTMLString:(NSString*) htmlString
{
    NSArray* episodeInfo = [OvercastHTMLParser episodeInfoListWithHTMLSting:htmlString];
    [OvercastEpisode listOfEpisodesWithEpisodeInfoArray:episodeInfo inManagedObjectContext:self.managedObjectContext];
    
    NSArray* podcastInfo = [OvercastHTMLParser podcastInfoListWithHTMLSting:htmlString];
    [OvercastPodcast listOfPodcastsWithEpisodeInfoArray:podcastInfo inManagedObjectContext:self.managedObjectContext];
    
    [self.managedObjectContext commitEditing];
    [[NSNotificationCenter defaultCenter] postNotificationName:MANAGED_OBJECT_CONTEXT_UPDATED_NOTIFICATION
                                                        object:nil];
    [self requestResponseRecived];
}

-(void)handlePodcastListPageHTMLString:(NSString*) htmlString
{
    NSArray* episodeInfo = [OvercastHTMLParser episodeInfoListWithAllEpisodesInPodcastHTMLSting:htmlString];
    if(episodeInfo.count == 0) return;
    [OvercastEpisode listOfEpisodesWithEpisodeInfoArray:episodeInfo forSpecificPodcast:[episodeInfo[0] objectForKey:PODCAST_TITLE] inManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext commitEditing];
    [[NSNotificationCenter defaultCenter] postNotificationName:MANAGED_OBJECT_CONTEXT_UPDATED_NOTIFICATION
                                                        object:nil];
    [self requestResponseRecived];
}

-(void) handleEpisodePlayerPage:(NSString*) htmlString
{
    NSDictionary* episodeInfo = [OvercastHTMLParser episodeDictionaryWithHTMLString:htmlString];
    OvercastEpisode* episode = [OvercastEpisode episodeWithEpisodeInfo:episodeInfo inManagedObjectContext:self.managedObjectContext];
    [episode updateWithEpisodeInfo:episodeInfo inManagedObjectContext:self.managedObjectContext shouldOverwrite:YES];
    [self.managedObjectContext commitEditing];
    //    [[OvercastEpisodePlayer sharedPlayer] loadPodcastFromEpisode:episode playWhenReady:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:EPISODE_INFO_LOADED_NOTIFICATION
                                                        object:self
                                                      userInfo:@{EPISODE_USER_INFO_KEY:episode}];
    [self requestResponseRecived];
}

#pragma mark - delete episode
-(void) deleteEpisodeWithID:(NSString*) episodeID
{
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"OvercastEpisode"];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", episodeID];
    NSError *error;
    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
    OvercastEpisode* episode;
    if (!results || results.count > 1) {
        NSLog(@"%@", error);
    }
    else if (results.count != 0){
        episode = [results firstObject];
        episode.isInLibrary = NO;
        if ([episode.uniqueID isEqualToString: [OvercastEpisodePlayer sharedPlayer].episode.uniqueID]) {
            [[OvercastEpisodePlayer sharedPlayer] unloadCurrentEpisode];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:MANAGED_OBJECT_CONTEXT_UPDATED_NOTIFICATION
                                                            object:nil];
    }
    
    [self deleteEpisode:episode requireRequest:NO];
}

-(void) deleteEpisode:(OvercastEpisode*) episode requireRequest:(BOOL)requireRequest
{
    if(episode.deletePodcastURL && !requireRequest)
    {
        [[OvercastSession sharedSession] sendRequestToUrlString:episode.deletePodcastURL.description withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {}];
    }
    else
    {
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://overcast.fm/%@", episode.uniqueID]];
        [[OvercastSession sharedSession] sendRequestToUrl:url
                                    withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
         {
             NSString* htmlString = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
             if (htmlString.length == 0) {
                 [self deleteEpisode:episode requireRequest:YES];
                 return;
             }
             NSDictionary* dict = [OvercastHTMLParser episodeDictionaryWithHTMLString:htmlString];
             NSString* itemID = [dict objectForKey:EPISODE_DATA_ITEM];
             NSString* deleteURL = [NSString stringWithFormat:@"https://overcast.fm/podcasts/delete_item/%@", itemID];
             if (itemID)
             {
                 NSURL* url = [NSURL URLWithString:deleteURL];
                 [[OvercastSession sharedSession] sendRequestToUrl:url withCompletionHandler:nil];
                 episode.isInLibrary = NO;
                 [[NSNotificationCenter defaultCenter] postNotificationName:MANAGED_OBJECT_CONTEXT_UPDATED_NOTIFICATION
                                                                     object:nil];
             }
         }];
    }
}


#pragma mark - Core Data Stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ciankm.Forecast" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
#ifdef DEBUG
    return [appSupportURL URLByAppendingPathComponent:@"Forecast_DEBUG"];
#else
    return [appSupportURL URLByAppendingPathComponent:@"Forecast"];
#endif
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Forecast" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"OSXCoreDataObjC.storedata"];
        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        
        
        NSString* dir = applicationDocumentsDirectory.path;
        NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:dir error:nil];
        for (NSString *filename in fileArray)  {
            [fileManager removeItemAtPath:[dir stringByAppendingPathComponent:filename] error:NULL];
        }
        return [self persistentStoreCoordinator];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}


@end
