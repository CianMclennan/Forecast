//
//  ViewController.h
//  SliderTest
//
//  Created by Cian McLennan on 08/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StackView.h"

@class NavigableViewController;

@interface NavigationViewController : NSViewController
@property (weak) IBOutlet StackView *stackView;

@property (weak) IBOutlet NSButton *backBtn;

-(NavigableViewController*) navigateToViewControllerWithIdentifier:(NSString*) storyboardID inStoryboardWithName:(NSString*) Storyboard;
-(void)navigateToViewController:(NavigableViewController*) navigableViewController;
-(void)navigateBack;
@end

