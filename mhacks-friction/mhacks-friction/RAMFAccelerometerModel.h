//
//  RAMFAccelerometerModel.h
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface RAMFAccelerometerModel : NSObject

@property CMMotionManager *motionManager;
@property CMAccelerometerData *accelData;

@end
