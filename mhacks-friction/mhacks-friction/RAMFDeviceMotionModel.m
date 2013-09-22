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
@property (nonatomic) double oldSpinRate;
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
        _oldSpinRate = 0;
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
    if (self.delegate) {
        if (fabs(self.oldSpinRate) < self.spinThreshold &&
            fabs(self.spinRate) > self.spinThreshold) {
            // crossed above threshold
            if ([self.delegate respondsToSelector:@selector(exceededThreshold)]) {
                [self.delegate exceededThreshold];
            }
        }
        if (fabs(self.oldSpinRate) > self.spinThreshold &&
            fabs(self.spinRate) < self.spinThreshold) {
            // crossed below threshold
            if ([self.delegate respondsToSelector:@selector(droppedBelowThreshold)]) {
                [self.delegate droppedBelowThreshold];
            }
        }
        if ((self.oldSpinRate > 0) != (self.spinRate)) {
            // changed direction
            if ([self.delegate respondsToSelector:@selector(directionChangedToClockwise:)]) {
                if (self.spinRate > 0) {
                    [self.delegate directionChangedToClockwise:YES];
                } else {
                    [self.delegate directionChangedToClockwise:NO];
                }
            }
        }
    }
    self.oldSpinRate = self.spinRate;
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
