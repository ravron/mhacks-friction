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
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setAccModel:[[RAMFAccelerometerModel alloc] init]];
    [[self accModel] setUpdating:YES];
    // register for notifications from the accelerometer model
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newAccelData:)
                                                 name:RAMFNewAccDataNotification
                                               object:nil];
}

- (void)newAccelData:(NSNotification *)note
{
    NSDictionary *uInfo = [note userInfo];
    double xAcc = [[uInfo objectForKey:RAMFAvgXAccDataKey] doubleValue];
    double yAcc = [[uInfo objectForKey:RAMFAvgYAccDataKey] doubleValue];
    double zAcc = [[uInfo objectForKey:RAMFAvgZAccDataKey] doubleValue];
    double delayRatio = [[uInfo objectForKey:RAMFDelayRatio] doubleValue];
    
    if ([[self bubbleView] isHidden] == NO) {
        [[self bubbleView] setIndicatorWithAccelerationsX:xAcc Y:yAcc Z:zAcc];
        [[self bubbleView] setLoadingRatio:delayRatio];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)unwindGraphView:(UIStoryboardSegue *)unwindSegue
{
    [[self accModel] setUpdating:NO];
}

- (RAMFAccelerometerModel *)getModel
{
    [[self accModel] setUpdating:YES];
    return [self accModel];
}

- (void)dealloc
{
    // must remove self from notification table if getting dealloc'd
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)testButtonPressed {
    [UIView animateWithDuration:0.5 animations:^{
        [[self bubbleView] setAlpha:0.0];
    } completion:^(BOOL finished){
        [[self bubbleView] setHidden:YES];
    }];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

@end
