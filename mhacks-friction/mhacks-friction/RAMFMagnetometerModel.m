//
//  RAMFMagnetometerModel.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFMagnetometerModel.h"

#define LOG_REFIRE_S 1.0

@interface RAMFMagnetometerModel ()
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic) BOOL isClockwise;
@property (nonatomic) BOOL isAboveThreshold;
@end

@implementation RAMFMagnetometerModel

- (id)initWithMotionManager:(CMMotionManager *)manager
{
    self = [super init];
    
    if (self) {
        _motionManager = manager;
        _monitorOrientation = NO;
    }
    return self;
}

- (void)setMonitorOrientation:(BOOL)monitorOrientation
{
    if (monitorOrientation == _monitorOrientation)
        return;
    
    if (monitorOrientation && !_monitorOrientation) {
        // turn it on AKA crank that bitch up
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    } else {
        [self.motionManager stopDeviceMotionUpdates];
        return;
    }
    
    _monitorOrientation = monitorOrientation;
    [self logOrientationPeriodic];
}

- (void)logOrientationPeriodic
{
    CMRotationRate rotRate = self.motionManager.deviceMotion.rotationRate;
    NSLog(@"%lf, %lf, %lf", rotRate.x, rotRate.y, rotRate.z);
    if (self.monitorOrientation) // call self back if still monitoring
        [self performSelector:@selector(logOrientationPeriodic) withObject:nil afterDelay:LOG_REFIRE_S];
}

@end
