//
//  RAMFMagnetometerModel.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFMagnetometerModel.h"

@interface RAMFMagnetometerModel ()
@property (strong, nonatomic) CMMotionManager *motionManager;
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

- (void)demoMagneticField
{
    CMCalibratedMagneticField mfield = self.motionManager.deviceMotion.magneticField;
    
    
}

- (void)startAccelerationCollection
{
    [self.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init]
                                            withHandler:^(CMDeviceMotion *motion, NSError *error) {
     dispatch_async(dispatch_get_main_queue(), ^{
         CMCalibratedMagneticField mfield = motion.magneticField;
         
     });
                                             }
     ];
}

@end
