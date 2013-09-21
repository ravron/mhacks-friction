//
//  RAMFFirstViewController.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFFirstViewController.h"

@interface RAMFFirstViewController ()

@end

@implementation RAMFFirstViewController

- (void)viewDidLoad
{
    
    UIImage *pewter = [UIImage imageNamed: @"brushed_pewter.png"];
    
    self.animation.animationImages = [NSArray arrayWithObjects:
                        [UIImage imageNamed:@"holding.gif"],
                        [UIImage imageNamed:@"sliding.gif"],
                        nil];
    
    self.animation.animationDuration = 1.0f;
    self.animation.animationRepeatCount = 0;
    [self.animation startAnimating];
    
    [[self backgroundImage] setImage: pewter];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setAccModel:[[RAMFAccelerometerModel alloc] init]];
    [self.accModel setShouldAverage:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)accelDataUpdateAvailable
{
    if ([self presentedViewController]) {
        if ([[self presentedViewController] conformsToProtocol:@protocol(RAMFAccelerometerModelDelegate)]) {
            
        }
    }
}

- (IBAction)unwindGraphView:(UIStoryboardSegue *)unwindSegue
{
    [[self accModel] setIsUpdating:NO];
}


- (RAMFAccelerometerModel *)getModel{
    [[self accModel] setIsUpdating:YES];
    return [self accModel];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
