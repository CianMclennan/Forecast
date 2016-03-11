//
//  AuthenticationWindowVC.m
//  Overcast
//
//  Created by Cian McLennan on 01/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "AuthenticationWindowVC.h"
#import "OvercastSession.h"
#import "AppDelegate.h"

@interface AuthenticationWindowVC ()

@end

@implementation AuthenticationWindowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![[[NSApplication sharedApplication] delegate] online]) {
        self.confirmButton.enabled = NO;
        [[NSNotificationCenter defaultCenter] addObserverForName:INTERNET_CONNECTION_CHANGED_NOTIFICATION
                                                          object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                                                              self.confirmButton.enabled = [[[NSApplication sharedApplication] delegate] online];
                                                          }];
    }
    if(self.errorMessage){
        self.errorMessageTF.stringValue = self.errorMessage;
    }
    NSString* usernameStr = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID];
    self.username.stringValue = usernameStr ? usernameStr : @"";
}

- (IBAction)confirmButtonPressed:(NSButton *)sender {
    [[OvercastSession sharedSession] loginWithUsername:self.username.stringValue andPassword:self.password.stringValue];
    [[[self view] window] close];
}

- (IBAction)cancelButtonPressed:(NSButton *)sender {
    [[[self view] window] close];
}

- (IBAction)forgotLinkPressed:(id)sender {
//    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://overcast.fm/forgot"]];
}
@end
