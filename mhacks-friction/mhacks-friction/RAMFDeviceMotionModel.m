//
//  RAMFMagnetometerModel.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFDeviceMotionModel.h"

#define SPIN_POLL_S 0.1
#define SPIN_THRESHOLD 0.7
#define SPIN_STOP_RATIO 4

@interface RAMFDeviceMotionModel ()
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (atomic) double spinRate;
@property (nonatomic) double oldSpinRate;
@property (nonatomic, strong) AVAudioPlayer *player;
@end

@implementation RAMFDeviceMotionModel

- (id)initWithMotionManager:(CMMotionManager *)manager
{
    self = [super init];
    
    if (self) {
        _motionManager = manager;
        _monitorOrientation = NO;
        _spinThreshold = SPIN_THRESHOLD;
        _spinStopRatio = SPIN_STOP_RATIO;
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
    if (fabs(self.spinRate) > self.spinThreshold) {
        [self.player setRate:1.0];
        [self.player play];
    } else if (fabs(self.spinRate) > (self.spinThreshold / self.spinStopRatio)) {
        // crossed below threshold, should rate-reduce
        double rate = 0.5 + (self.spinRate - (self.spinThreshold / self.spinStopRatio)) * 0.5;
        [self.player setRate:rate];
        [self.player play];
        
        if (self.oldSpinRate < (self.spinThreshold / self.spinStopRatio)) {
            // crossed from off to on, should notify
            if (self.delegate && [self.delegate respondsToSelector:@selector(exceededThreshold)]) {
                [self.delegate exceededThreshold];
            }
        }
    } else {
        if (fabs(self.oldSpinRate > (self.spinThreshold / self.spinStopRatio))) {
            // into off-territory, should turn off, notify delegate
            if (self.delegate && [self.delegate respondsToSelector:@selector(droppedBelowThreshold)]) {
                [self.delegate droppedBelowThreshold];
            }
        }
        [self.player pause];
        [self.player setRate:0.5];
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

- (AVAudioPlayer *)player
{
    if (!_player) {
        NSString *soundFilePath =
        [[NSBundle mainBundle] pathForResource: @"Eine_kleine"
                                        ofType: @"mp3"];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                         error: nil];
        [_player prepareToPlay];
        [_player setNumberOfLoops:-1];
        [_player setEnableRate:YES];
        [_player setDelegate: self];
    }
    return _player;
}

@end
