//
//  RAMFAccelerometerModel.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFAccelerometerModel.h"

@implementation RAMFAccelerometerModel

- (id)init
{
    self = [super init];
    
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        [_motionManager startAccelerometerUpdates];
        _isUpdating = FALSE;
    }
    
    return self;
}

- (void)updateAccelerometerData
{
    [self setAccelData:[[self motionManager] accelerometerData]];
    double xyAccel = 0.0;
    double xAccel, yAccel;
    CMAcceleration accelStruct = [[self accelData] acceleration];

    xAccel = accelStruct.x;
    yAccel = accelStruct.y;
    
    xyAccel = sqrt(pow(xAccel, 2) + pow(yAccel, 2));
    [self setRawAccel:xyAccel];
    
    if (self.isUpdating) {
        NSTimeInterval delay = 1;
        [self performSelector:@selector(updateAccelerometerData) withObject:nil afterDelay:delay];
    }
    
    [self logAccelData];
}

- (void)logAccelData
{
    NSLog(@"%lf", [self rawAccel]);
    [[[ vc] dataField] setText:@"%lf", [self rawAccel]];
}


@end
