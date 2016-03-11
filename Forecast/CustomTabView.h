//
//  CustomTabView.h
//  Forecast
//
//  Created by Cian McLennan on 10/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomTabView : NSViewController
@property (weak) IBOutlet NSTabView *tabView;
- (IBAction)tabButtonPressed:(NSButton*)sender;
@property (weak) IBOutlet NSButton* libButton;
@property (weak) IBOutlet NSButton* podcastButton;

@end
