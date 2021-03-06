//
//  RAMFMagnetometerModel.h
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

@protocol RAMFDeviceMotionModelDelegate <NSObject>

@optional
- (void)exceededThreshold;
- (void)droppedBelowThreshold;

@end

@interface RAMFDeviceMotionModel : NSObject <AVAudioPlayerDelegate>

@property (strong, nonatomic, readonly) CMMotionManager *motionManager;
@property (nonatomic) BOOL monitorOrientation;
@property (atomic, readonly) double spinRate;
@property (weak, nonatomic) NSObject <RAMFDeviceMotionModelDelegate> *delegate;

@property (nonatomic) double spinThreshold;
@property (nonatomic) double spinStopRatio;

- (id)initWithMotionManager:(CMMotionManager *)manager;
- (id) init __attribute__((unavailable("Must use initWithMotionManager: instead.")));
- (BOOL)isClockwise;
- (BOOL)isAboveThreshold;

@end
