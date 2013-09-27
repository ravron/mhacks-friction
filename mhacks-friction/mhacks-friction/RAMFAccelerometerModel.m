//
//  RAMFAccelerometerModel.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFAccelerometerModel.h"

#define ACCEL_UPDATE_INTERVAL 0.5
#define AVG_SIZE 10
#define RAD_TO_DEG(radians) ((radians) * (180.0 / M_PI))

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
        [_motionManager setAccelerometerUpdateInterval:ACCEL_UPDATE_INTERVAL];
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
    
    double rawX = accData.acceleration.x;
    double rawY = accData.acceleration.y;
    double rawZ = accData.acceleration.z;
    
    // check if we've accumulated enough data points for a full average
    if ([[self avgAccDataArr] count] >= AVG_SIZE) {
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
    
    BOOL hold = [self matchToHoldWithXValue:avgX yValue:avgY zValue:avgZ];
    
    // assemble dictionary with NSNumber-wrapped acceleration values, angles,
    // and constant keys
    NSDictionary *accelerationDict =
    @{RAMFRawXAccDataKey   : @(rawX), RAMFRawYAccDataKey : @(rawY),
      RAMFRawZAccDataKey   : @(rawZ), RAMFAvgXAccDataKey : @(avgX),
      RAMFAvgYAccDataKey   : @(avgY), RAMFAvgZAccDataKey : @(avgZ),
      RAMFRawXAngleDataKey : @(rawAngleToX), RAMFRawYAngleDataKey : @(rawAngleToY),
      RAMFRawZAngleDataKey : @(rawAngleToZ), RAMFAvgXAngleDataKey : @(avgAngleToX),
      RAMFAvgYAngleDataKey : @(rawAngleToY), RAMFAvgZAngleDataKey : @(avgAngleToZ)};
    
    // post notification of new data containing dictionary with data
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:RAMFNewAccDataNotification
                          object:self
                        userInfo:accelerationDict];
}

- (BOOL)matchToHoldWithXValue:(double)x yValue:(double)y zValue:(double)z
{
    double magnitude = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));
    double windowSize = 0.015;
    
    if (z > -1 + windowSize || z < -1 - windowSize) {
        return NO;
    } else if (magnitude < 0.98 || magnitude > 1.02) {
        return NO;
    }
    
    return YES;
}

@end
