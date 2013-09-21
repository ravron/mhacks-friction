//
//  RAMFAccelerometerModel.h
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@protocol RAMFAccelerometerModelDelegate <NSObject>

- (void)accelDataUpdateAvailable;

@end

@interface RAMFAccelerometerModel : NSObject

@property CMMotionManager *motionManager;
@property CMAccelerometerData *accelData;
@property double rawAccel;
@property BOOL isUpdating;
@property (weak, nonatomic) id <RAMFAccelerometerModelDelegate> delegate;

- (void)updateAccelerometerData;

@end
