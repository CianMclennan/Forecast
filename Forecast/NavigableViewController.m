//
//  NavigableViewController.m
//  SliderTest
//
//  Created by Cian McLennan on 09/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "NavigableViewController.h"

@interface NavigableViewController ()

@end

@implementation NavigableViewController

-(void) wasNavigatedTo
{
    
}

-(BOOL) isFirstControllerInStack
{
    return self.navigationViewContoller.stackView.count == 1;
}

@end
