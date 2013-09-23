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
#import "RAMFAccelerometerModelDelegate.h"

typedef enum _TrackingState {
    TrackingStateNotTracking = 0,
    TrackingStateRisingPush = 1,
    TrackingStateFallingPush = 2,
    TrackingStateRisingSlide = 3
} TrackingState;

@interface RAMFAccelerometerModel : NSObject <CPTScatterPlotDataSource>
{
    @private
    BOOL _isUpdating;
}

@property (nonatomic, readonly) CMMotionManager *motionManager;

@property (nonatomic) BOOL isUpdating;
@property (weak, nonatomic) NSObject <RAMFAccelerometerModelDelegate> *delegate;
@property (nonatomic) BOOL shouldAverage;
@property (nonatomic) int averagingValue;
@property (nonatomic) double mu;
@property (nonatomic, readonly) TrackingState trackState;

- (NSArray *)xAxisExtrema;
- (NSArray *)yAxisExtrema;

@end
