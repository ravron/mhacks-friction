//
//  RAMFMagnetometerModel.h
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface RAMFMagnetometerModel : NSObject

@property (strong, nonatomic, readonly) CMMotionManager *motionManager;
@property (nonatomic) BOOL monitorOrientation;

@end
