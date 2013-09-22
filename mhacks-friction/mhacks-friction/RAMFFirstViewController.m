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
    
    UIImage *pewter = [UIImage imageNamed: @"title.png"];
    
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
    
    [self setDevMotionModel:[[RAMFDeviceMotionModel alloc] initWithMotionManager:[[self accModel] motionManager]]];
    [self.devMotionModel setMonitorOrientation:YES];
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


- (IBAction)unwindRecordView:(UIStoryboardSegue *)unwindSegue
{
//Leave empty
}

- (void)exceededThreshold
{
    if([self presentedViewController] ) {
        if([[self presentedViewController] isKindOfClass: [RAMFRecordViewController class]]){
            [(RAMFRecordViewController *)[self presentedViewController] startSpinning];
        }
    }
}

- (void)droppedBelowThreshold
{
    if([self presentedViewController] ) {
        if([[self presentedViewController] isKindOfClass: [RAMFRecordViewController class]]){
            [(RAMFRecordViewController *)[self presentedViewController] stopSpinning];
        }
    }
}

- (void)directionChangedToClockwise:(BOOL)clockwise
{
    if([self presentedViewController] ) {
        if([[self presentedViewController] isKindOfClass: [RAMFRecordViewController class]]){
            [(RAMFRecordViewController *)[self presentedViewController] startSpinning];
        }
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
