//
//  RAMFAccelerometerModel.h
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "CorePlot-CocoaTouch.h"

@protocol RAMFAccelerometerModelDelegate <NSObject>

- (void)accelDataUpdateAvailable;

@end

@interface RAMFAccelerometerModel : NSObject <CPTScatterPlotDataSource>
{
    @private
    BOOL _isUpdating;
}

@property (nonatomic, readonly) CMMotionManager *motionManager;
@property (nonatomic, readonly) CMAccelerometerData *accelData;
@property (readonly) double rawAccel;
@property (nonatomic) BOOL isUpdating;
@property (weak, nonatomic) id <RAMFAccelerometerModelDelegate> delegate;

@end
