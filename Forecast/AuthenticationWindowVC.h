//
//  AuthenticationWindowVC.h
//  Overcast
//
//  Created by Cian McLennan on 01/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AuthenticationWindowVC : NSViewController
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSSecureTextField *password;
@property (weak) IBOutlet NSButton *confirmButton;
@property (weak) IBOutlet NSTextField *errorMessageTF;
@property (nonatomic) NSString* errorMessage;

- (IBAction)confirmButtonPressed:(NSButton *)sender;
- (IBAction)cancelButtonPressed:(NSButton *)sender;
- (IBAction)forgotLinkPressed:(id)sender;

@end
