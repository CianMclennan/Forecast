//
//  OfflineVC.h
//  Forecast
//
//  Created by Cian McLennan on 06/03/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OfflineVC : NSViewController
@property (weak) IBOutlet NSTextField *offlineText;
@property (weak) IBOutlet NSButton *signInButton;
- (IBAction)signInButtonPressed:(id)sender;

@end
