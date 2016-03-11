//
//  ViewController.h
//  SliderTest
//
//  Created by Cian McLennan on 08/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface StackView : NSView

@property (readonly) CATransition * animation;
@property (readonly) NSUInteger count;
@property (readonly) NSViewController* currentViewController;

- (NSViewController*)popView;
- (void)pushView:(NSViewController*) newView;

@end

