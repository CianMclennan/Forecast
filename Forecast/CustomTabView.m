//
//  CustomTabView.m
//  Forecast
//
//  Created by Cian McLennan on 10/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "CustomTabView.h"
#import "AppDelegate.h"
#import "OvercastSession.h"

@implementation CustomTabView
{
    NSArray* _buttons;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:INTERNET_CONNECTION_CHANGED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self updateCurrentTab];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SIGN_IN_STATE_CHANGED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self updateCurrentTab];
                                                  }];
    _buttons = @[_libButton, _podcastButton];
    [self setButtonToDeselected:_podcastButton];
}
-(void) updateCurrentTab
{
    AppDelegate* appDelegate = NSApplication.sharedApplication.delegate;
    BOOL isSignedIn = [[OvercastSession sharedSession] isLoggedIn];
    if(!isSignedIn || !appDelegate.online) {
        for (NSButton* button in _buttons) {
            button.enabled = NO;
        }
        [self.tabView selectTabViewItemWithIdentifier: @"Offline"];
    }
    else if (appDelegate.online && isSignedIn && [[[self.tabView selectedTabViewItem] identifier] isEqualToString:@"Offline"])
    {
        for (NSButton* button in _buttons) {
            button.enabled = appDelegate.online;
        }
        [self.tabView selectTabViewItemWithIdentifier: @"Library"];
    }
}

- (IBAction)tabButtonPressed:(NSButton*)sender {
    [self.tabView selectTabViewItemWithIdentifier:sender.title];
    for (NSButton* button in _buttons) {
        [self setButtonToDeselected:button];
    }
    [self setButtonToSelected:sender];
}

- (void) setButtonToSelected:(NSButton*) button
{
    NSString* name = button.image.name;
    NSRange selected = [name rangeOfString:@"_deselected"];
    if (selected.location == NSNotFound) return;
    button.image = [NSImage imageNamed: [name substringToIndex:selected.location]];
}
- (void) setButtonToDeselected:(NSButton*) button
{
    NSString* name = button.image.name;
    NSRange selected = [name rangeOfString:@"_deselected"];
    if (selected.location != NSNotFound) return;
    button.image = [NSImage imageNamed: [NSString stringWithFormat:@"%@_deselected", name]];
}

@end
