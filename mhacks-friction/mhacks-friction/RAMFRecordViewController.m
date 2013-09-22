//
//  RAMFRecordViewController.m
//  mhacks-friction
//
//  Created by Van Wittekind on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFRecordViewController.h"

@interface RAMFRecordViewController ()

@end

@implementation RAMFRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.RecordImage setImage: [UIImage imageNamed: @"record1.png"]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)startSpinning
{
    [self.RecordImage setImage: [UIImage imageNamed: @"record2.png"]];
}

- (void)stopSpinning
{
    [self.RecordImage setImage: [UIImage imageNamed: @"record1.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end