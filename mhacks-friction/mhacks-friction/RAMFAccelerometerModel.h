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
#import "math.h"

typedef enum _TrackingState {
    TrackingStateNotTracking = 0,
    TrackingStateRisingPush = 1,
    TrackingStateFallingPush = 2,
    TrackingStateRisingSlide = 3
} TrackingState;

// raw and average X, Y, and Z data
extern NSString *const RAMFRawXAccDataKey;
extern NSString *const RAMFRawYAccDataKey;
extern NSString *const RAMFRawZAccDataKey;
extern NSString *const RAMFAvgXAccDataKey;
extern NSString *const RAMFAvgYAccDataKey;
extern NSString *const RAMFAvgZAccDataKey;
// raw and average angles-to-X, -Y, and -Z data
extern NSString *const RAMFRawXAngleDataKey;
extern NSString *const RAMFRawYAngleDataKey;
extern NSString *const RAMFRawZAngleDataKey;
extern NSString *const RAMFAvgXAngleDataKey;
extern NSString *const RAMFAvgYAngleDataKey;
extern NSString *const RAMFAvgZAngleDataKey;
// ratio, from 0 to 1, of how much of delay goal is currently met
extern NSString *const RAMFDelayRatio;
// actual notification key (name), sent out whenever new
// data is available
extern NSString *const RAMFNewAccDataNotification;

@class RAMFAccelerometerModel;

// delegate protocol for the view controller that uses this model
@protocol RAMFAccelerometerModelDelegate <NSObject>

@required
- (void)accelerometerModel:(RAMFAccelerometerModel *)model didReceiveNewOrientation:(NSDictionary *)orientation;

@end

@interface RAMFAccelerometerModel : NSObject
{
    @private
    BOOL _isUpdating;
}

@property (nonatomic, readonly) CMMotionManager *motionManager;

@property (nonatomic, getter = isUpdating) BOOL updating;
@property (nonatomic, readonly) TrackingState trackState;

- (NSData *)dataForLog;

//- (NSArray *)xAxisExtrema;
//- (NSArray *)yAxisExtrema;

@end

