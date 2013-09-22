//
//  RAMFMagnetometerModel.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFDeviceMotionModel.h"

#define SPIN_POLL_S 0.5

@interface RAMFDeviceMotionModel ()
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (atomic) double spinRate;
@end

@implementation RAMFDeviceMotionModel

- (id)initWithMotionManager:(CMMotionManager *)manager
{
    self = [super init];
    
    if (self) {
        _motionManager = manager;
        _monitorOrientation = NO;
        _spinThreshold = 0.75;
        _spinRate = 0;
    }
    return self;
}

- (void)setMonitorOrientation:(BOOL)monitorOrientation
{
    if (monitorOrientation == _monitorOrientation)
        return;
    
    if (monitorOrientation && !_monitorOrientation) {
        // turn it on AKA crank that bitch up
        [self.motionManager setDeviceMotionUpdateInterval:SPIN_POLL_S];
        [self.motionManager
         startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
         toQueue:[[NSOperationQueue alloc] init]
         withHandler:^(CMDeviceMotion *motion, NSError *err) {
             CMRotationRate rotRate = motion.rotationRate;
             [self setSpinRate:rotRate.z];
             [self performSelectorOnMainThread:@selector(newSpinRateAvailable) withObject:nil waitUntilDone:NO];
         }];
    } else {
        [self.motionManager stopDeviceMotionUpdates];
    }
    _monitorOrientation = monitorOrientation;
}

- (void)newSpinRateAvailable
{
    
}

#pragma mark - Getters

- (BOOL)isClockwise
{
    CMRotationRate rotRate = self.motionManager.deviceMotion.rotationRate;
    if (rotRate.z > 0)
        return YES;
    return NO;
}

- (BOOL)isAboveThreshold
{
    CMRotationRate rotRate = self.motionManager.deviceMotion.rotationRate;
    if (fabs(rotRate.z) > self.spinThreshold)
        return YES;
    return NO;
}

@end
