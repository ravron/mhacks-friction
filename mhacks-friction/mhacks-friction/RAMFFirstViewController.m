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
    [self.accModel setShouldAverage:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)accelDataUpdateAvailable
{
    
}

- (IBAction)unwindGraphView:(UIStoryboardSegue *)unwindSegue
{
    [[self accModel] setIsUpdating:NO];
}

- (RAMFAccelerometerModel *)getModel{
    [[self accModel] setIsUpdating:YES];
    return [self accModel];
}

//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

@end
