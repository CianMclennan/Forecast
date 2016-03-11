//
//  OfflineVC.m
//  Forecast
//
//  Created by Cian McLennan on 06/03/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "OfflineVC.h"
#import "AppDelegate.h"

@interface OfflineVC ()

@end

@implementation OfflineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:INTERNET_CONNECTION_CHANGED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self updateViewForOfflineStatus];
                                                  }];
}

-(void)viewWillAppear
{
    [self updateViewForOfflineStatus];
}

-(void)updateViewForOfflineStatus
{
    self.offlineText.hidden = [[[NSApplication sharedApplication] delegate] online];
    self.signInButton.hidden = !self.offlineText.hidden;
}
- (IBAction)signInButtonPressed:(id)sender {
    [[[NSApplication sharedApplication] delegate] presentAuthenticationDialogWithErrorMessage:nil];
}
@end
