//
//  RAMFAccelerometerModel.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFAccelerometerModel.h"

// convenience macro for rad to deg conversion
#define RAD_TO_DEG(radians) ((radians) * (180.0 / M_PI))

// numeric constants related to model behavior
// desired period for accelerometer updates (min. 0.01)
NSTimeInterval const accelerometerUpdateInterval = 0.01;
// number of previous accelerometer values to average for averaged data
NSUInteger const averageSize = 10;
// how long to wait in holding position "invisibly" before contacting
// view controller
NSTimeInterval const holdStatePreDelay = 0.25;
// how long to wait before deciding that hold state has been completed
NSTimeInterval const holdStateDelay = 1.0;


// string constants related to notification sending
NSString *const RAMFRawXAccDataKey = @"RAMFRawXAccDataKey";
NSString *const RAMFRawYAccDataKey = @"RAMFRawYAccDataKey";
NSString *const RAMFRawZAccDataKey = @"RAMFRawZAccDataKey";
NSString *const RAMFAvgXAccDataKey = @"RAMFAvgXAccDataKey";
NSString *const RAMFAvgYAccDataKey = @"RAMFAvgYAccDataKey";
NSString *const RAMFAvgZAccDataKey = @"RAMFAvgZAccDataKey";
NSString *const RAMFRawXAngleDataKey = @"RAMFRawXAngleDataKey";
NSString *const RAMFRawYAngleDataKey = @"RAMFRawYAngleDataKey";
NSString *const RAMFRawZAngleDataKey = @"RAMFRawZAngleDataKey";
NSString *const RAMFAvgXAngleDataKey = @"RAMFAvgXAngleDataKey";
NSString *const RAMFAvgYAngleDataKey = @"RAMFAvgYAngleDataKey";
NSString *const RAMFAvgZAngleDataKey = @"RAMFAvgZAngleDataKey";
NSString *const RAMFDelayRatio       = @"RAMFDelayRatio";
NSString *const RAMFNewAccDataNotification = @"RAMFNewAccDataNotification";

@interface RAMFAccelerometerModel ()

@property (nonatomic, strong) CMMotionManager *motionManager;
// accData will always hold the most recent accelerometer data
@property (nonatomic, strong) CMAccelerometerData *accData;
// avgAccDataArr holds the last AVG_SIZE measurements to provide
// averaged values when tracking but not updating
@property (nonatomic, strong) NSMutableArray *avgAccDataArr;
@property (nonatomic, strong) NSMutableArray *accDataArr;

// beginningOfHold stores the start time of a static hold behavior.  e.g. the
// phone is put into a satisfactory hold position at timestamp == 400, then
// beginningOfHold = 400.  when there's no hold "streak" occurring, beginningOfHold
// is 0 as a sentinel value.
@property (nonatomic) NSTimeInterval beginningOfHold;
@property (nonatomic) TrackingState trackState;

@property (nonatomic) NSTimeInterval dataTimeOffset;

@end

@implementation RAMFAccelerometerModel

- (id)init
{
    self = [super init];
    
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        [_motionManager setAccelerometerUpdateInterval:accelerometerUpdateInterval];
        _isUpdating = NO;
        _avgAccDataArr = [NSMutableArray array];
        
        _beginningOfHold = 0.0;
        _trackState = TrackingStateNotTracking;
    }
    
    return self;
}

- (void)setUpdating:(BOOL)isUpdating
{
    // if no value change, return
    if (isUpdating == _isUpdating)
        return;

    // if we're turning on updating
    if (isUpdating && !_isUpdating) {
        NSLog(@"Activating updates");
        [[self accDataArr] removeAllObjects];
        [self setDataTimeOffset:0];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [[self motionManager] startAccelerometerUpdatesToQueue:queue
                                                   withHandler:
         // this is where the accelerometer update handler begins...
         ^(CMAccelerometerData *data,
           NSError *err) {
             // check for accelerometer error
             if (err) {
                 [[self motionManager] stopAccelerometerUpdates];
                 NSLog(@"There was an accelerometer error:");
                 NSLog(@"%@", err);
                 return;
             }
             // if there is no error, dispatch asynchronously to the main queue, setting the data
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self setAccData:data];
             });  // end of dispatch block
         }]; // end of accel update handler block
    } else {
        // else we're turning off updating
        [[self motionManager] stopAccelerometerUpdates];
    }
    
    // make sure to assign ivar
    _isUpdating = isUpdating;
}

/* 
 * Nominally the setter for _accData, will be called async when
 * the motion manager calls the handler block defined in setUpdating
 */
- (void)setAccData:(CMAccelerometerData *)accData
{
    _accData = accData;
    
    NSTimeInterval timestamp = [accData timestamp];
    
    double rawX = accData.acceleration.x;
    double rawY = accData.acceleration.y;
    double rawZ = accData.acceleration.z;
    
    // check if we've accumulated enough data points for a full average
    if ([[self avgAccDataArr] count] >= averageSize) {
        // if yes, remove the oldest (index 0)
        [[self avgAccDataArr] removeObjectAtIndex:0];
    }
    // then append newest acceleration data to array's end
    [[self avgAccDataArr] addObject:accData];
    
    double sumX = 0, sumY = 0, sumZ = 0;
    double avgX, avgY, avgZ;
    int i = 0;
    for (CMAccelerometerData *data in [self avgAccDataArr]) {
        sumX += data.acceleration.x;
        sumY += data.acceleration.y;
        sumZ += data.acceleration.z;
        i++;
    }
    
    // note that this average is "usually"/"eventually" going to be
    // an average over AVG_SIZE elements; at the beginning of data collection,
    // though, it averages over all available data points until AVG_SIZE
    // data points have been acquired
    NSUInteger avgSize = [[self avgAccDataArr] count];
    avgX = sumX / avgSize;
    avgY = sumY / avgSize;
    avgZ = sumZ / avgSize;
    
    // calculate the angle between the composite acceleration vector and
    // each axis' positive direction (i.e. +X, +Y, +Z) in radians
    double rawVectorLength = sqrt(pow(rawX, 2) + pow(rawY, 2) + pow(rawZ, 2));
    double avgVectorLength = sqrt(pow(avgX, 2) + pow(avgY, 2) + pow(avgZ, 2));
    double rawAngleToX, rawAngleToY, rawAngleToZ;
    double avgAngleToX, avgAngleToY, avgAngleToZ;
    
    if (rawVectorLength != 0) {
        // prevent the unlikely divide-by-zero (if zero vector length,
        // pretend we're level)
        rawAngleToX = acos(rawX / rawVectorLength);
        rawAngleToY = acos(rawY / rawVectorLength);
        rawAngleToZ = acos(rawZ / rawVectorLength);
    } else {
        rawAngleToX = M_PI_2;
        rawAngleToY = M_PI_2;
        rawAngleToZ = M_PI;
        
    }
    
    if (avgVectorLength != 0) {
        avgAngleToX = acos(avgX / avgVectorLength);
        avgAngleToY = acos(avgY / avgVectorLength);
        avgAngleToZ = acos(avgZ / avgVectorLength);
    } else {
        avgAngleToX = M_PI_2;
        avgAngleToY = M_PI_2;
        avgAngleToZ = M_PI;
    }
    
    BOOL isHolding = [self matchToHoldWithMagnitude:avgVectorLength angleToZ:avgAngleToZ];
    NSTimeInterval holdDuration = 0.0;
    double delayRatio = 0;
    if (isHolding == YES) {
        if ([self beginningOfHold] <= 0.0) {
            // this is the beginning of a holding "streak"
            [self setBeginningOfHold:timestamp];
        } else {
            // the hold has been going on
            // calculate how long the hold has been going, allowing for the predelay
            holdDuration = timestamp - [self beginningOfHold] - holdStatePreDelay;
            // bounds check in case predelay puts it negative
            if (holdDuration < 0)
                holdDuration = 0;
            // ratio indicating how much of delay has been traversed thus far
            delayRatio = holdDuration / holdStateDelay;
            // bounds check
            if (delayRatio > 1.0)
                delayRatio = 1.0;
        }
    } else {
        // if hold is broken, reset beginningOfHold to sentinel 0
        [self setBeginningOfHold:0.0];
    }
    
    // assemble dictionary with NSNumber-wrapped acceleration values, angles,
    // and constant keys
    NSDictionary *accelerationDict =
    @{RAMFRawXAccDataKey   : @(rawX), RAMFRawYAccDataKey : @(rawY),
      RAMFRawZAccDataKey   : @(rawZ), RAMFAvgXAccDataKey : @(avgX),
      RAMFAvgYAccDataKey   : @(avgY), RAMFAvgZAccDataKey : @(avgZ),
      RAMFRawXAngleDataKey : @(rawAngleToX), RAMFRawYAngleDataKey : @(rawAngleToY),
      RAMFRawZAngleDataKey : @(rawAngleToZ), RAMFAvgXAngleDataKey : @(avgAngleToX),
      RAMFAvgYAngleDataKey : @(rawAngleToY), RAMFAvgZAngleDataKey : @(avgAngleToZ),
      RAMFDelayRatio       : @(delayRatio)};
    
    // post notification of new data containing dictionary with data
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:RAMFNewAccDataNotification
                          object:self
                        userInfo:accelerationDict];
}

- (BOOL)matchToHoldWithMagnitude:(double)magnitude angleToZ:(double)angleToZ
{
    if (magnitude < 0.98 || magnitude > 1.02)
        return NO;
    else if (angleToZ < M_PI * 0.98)
        return NO;
    
    return YES;
}

@end
