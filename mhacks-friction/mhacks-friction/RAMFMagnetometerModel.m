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



@end
