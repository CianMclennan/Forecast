//
//  ViewController.m
//  SliderTest
//
//  Created by Cian McLennan on 08/02/2016.
//  Copyright © 2016 Cian McLennan. All rights reserved.
//

#import "StackView.h"

@interface StackView ()

@property (nonatomic) NSMutableArray* viewStack;
@property (nonatomic) CATransition * animation;

@end

@implementation StackView

-(instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self setUp];
    }
    return self;
}
-(instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        [self setUp];
    }
    return self;
}
- (void)setUp
{
    self.viewStack =[[NSMutableArray alloc] init];
    
    self.animation = [CATransition animation];
    self.animation.type = kCATransitionPush;
    self.animation.subtype = kCATransitionFromLeft;
    self.animation.duration = 0.25f;
    self.animation.delegate = self;
    self.animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self setWantsLayer:YES]; // Turn on backing layer
    [self setAnimations:[NSDictionary dictionaryWithObject:self.animation forKey:@"subviews"]];
}

-(void) pushToStack:(NSViewController*) view{
    [self.viewStack addObject:view];
}

-(NSViewController*) popFromStack
{
    NSViewController* view = [self.viewStack lastObject];
    [self.viewStack removeLastObject];
    return view;
}

- (NSViewController*)popView
{
    self.animation.subtype = kCATransitionFromLeft;
    NSViewController* currentView = [self popFromStack];
    NSViewController* previousView = [self.viewStack lastObject];
    if (previousView.view) {
        [[self animator] replaceSubview:currentView.view with:previousView.view];
        previousView.view.frame = self.frame;
        [previousView.view setNeedsDisplay:YES];
    }
    else if(currentView.view)
    {
        [currentView.view removeFromSuperview];
    }
    return currentView;
}
- (void)pushView:(NSViewController*) newView {
    self.animation.subtype = kCATransitionFromRight;
    
    newView.view.frame = self.frame;
    
    
    NSViewController* currentView = [self.viewStack lastObject];
    
    if (currentView) {
        [[self animator] replaceSubview:currentView.view with:newView.view];
    }
    else{
        [self addSubview:newView.view];
    }
    [self pushToStack:newView];
}

-(NSUInteger)count
{
    return self.viewStack.count;
}
-(NSViewController *)currentView
{
    return [self.viewStack lastObject];
}
-(void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    NSView* view = [[self subviews] firstObject];
    view.frame = self.frame;
    [view setNeedsDisplay:YES];
}
@end
