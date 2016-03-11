//
//  NavigableViewController.h
//  SliderTest
//
//  Created by Cian McLennan on 09/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NavigationViewController.h"

@interface NavigableViewController : NSViewController
@property (nonatomic) NavigationViewController* navigationViewContoller;
-(void) wasNavigatedTo;
-(BOOL) isFirstControllerInStack;
@end
