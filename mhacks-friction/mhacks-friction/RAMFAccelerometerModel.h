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

typedef enum _TrackingState {
    TrackingStateNotTracking = 0,
    TrackingStateRisingPush = 1,
    TrackingStateFallingPush = 2,
    TrackingStateRisingSlide = 3
} TrackingState;

extern NSString *const RAMFAccNotificationDataKey;
extern NSString *const RAMFNewAccDataNotification;


@interface RAMFAccelerometerModel : NSObject
{
    @private
    BOOL _isUpdating;
}

@property (nonatomic, readonly) CMMotionManager *motionManager;

@property (nonatomic, getter = isUpdating) BOOL updating;
@property (nonatomic, readonly) TrackingState trackState;

//- (NSArray *)xAxisExtrema;
//- (NSArray *)yAxisExtrema;

@end
