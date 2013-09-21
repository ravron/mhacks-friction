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
    /*
    UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"image1.gif"],
                                         [UIImage imageNamed:@"image2.gif"],
                                         [UIImage imageNamed:@"image3.gif"],
                                         [UIImage imageNamed:@"image4.gif"], nil];
    animatedImageView.animationDuration = 1.0f;
    animatedImageView.animationRepeatCount = 0;
    [animatedImageView startAnimating];
    [self.view addSubview: animatedImageView];
     */
    
    [[self backgroundImage] setImage: pewter];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setAccModel:[[RAMFAccelerometerModel alloc] init]];
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
    NSLog(@"Get model called");
    [[self accModel] setIsUpdating:YES];
    return [self accModel];
}

@end
