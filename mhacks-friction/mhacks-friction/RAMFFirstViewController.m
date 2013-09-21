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
    [[self dataField] setText:@"Hi"];
    [self setAccModel:[[RAMFAccelerometerModel alloc] init]];
    [[self accModel] setIsUpdating:YES];
    [[self accModel] updateAccelerometerData];
    //double myaccel = [[self accModel] rawAccel];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)accelDataUpdateAvailable
{
    
}

- (IBAction)startAction:(id)sender {
}
@end
