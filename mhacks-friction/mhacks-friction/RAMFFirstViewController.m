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
    
    [self dataField].backgroundColor = [UIColor colorWithRed:0.2f green:0.3f blue:0.4f alpha:0.50001f];
    
    [[self dataField] setText:@"Not Updated"];
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

- (IBAction)swapTextFieldColor:(UIButton *)sender {
    [self dataField].backgroundColor = [UIColor colorWithRed:.5 green:.1 blue:.6 alpha:0.50001f];
    [[self dataField] setText:@"Fuck you"];
}

- (RAMFAccelerometerModel *) getModel{
    [[self accModel] setIsUpdating:YES];
    return [self accModel];
}

@end
