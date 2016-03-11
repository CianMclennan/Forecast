//
//  ViewController.m
//  SliderTest
//
//  Created by Cian McLennan on 08/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "NavigationViewController.h"
#import "NavigableViewController.h"

@interface NavigationViewController ()

@property (nonatomic) NSRect buttonStartingPos;
@property (nonatomic) NSRect buttonAnimationStartingPos;

@end

@implementation NavigationViewController

-(void)viewDidLoad
{
    [self.backBtn setAction:@selector(backButtonPressed)];
    [self.backBtn setTarget:self];
}
-(void)viewWillAppear
{
    if (self.stackView.count < 2)
    {
        self.backBtn.enabled = NO;
    }
}

-(NavigableViewController*) navigateToViewControllerWithIdentifier:(NSString*) storyboardID inStoryboardWithName:(NSString*) Storyboard
{
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:Storyboard bundle:[NSBundle mainBundle]];
    NavigableViewController* vc = [storyboard instantiateControllerWithIdentifier:storyboardID];
    [self navigateToViewController:vc];
    return vc;
}

-(void)navigateToViewController:(NavigableViewController*) navigableViewController
{
    navigableViewController.navigationViewContoller = self;
    [self.stackView pushView:navigableViewController];
    self.backBtn.enabled = YES;
    
    [navigableViewController wasNavigatedTo];
}
-(void)navigateBack
{
    [self.stackView popView];
    NavigableViewController* view = (NavigableViewController*)[self.stackView currentViewController];
    if (self.stackView.count < 2) {
        self.backBtn.enabled = NO;
    }
    if (view) [view wasNavigatedTo];
}

- (void)backButtonPressed {
    [self navigateBack];
}

@end
