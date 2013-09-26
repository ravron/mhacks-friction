//
//  RAMFAccelerometerModel.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFAccelerometerModel.h"

#define ACCEL_UPDATE_INTERVAL 0.01
#define AVG_SIZE 40
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
        
        _trackState = TrackingStateNotTracking;
    }
    
    return self;
}

// old periodic updateAccelerometerData
/*
- (void)updateAccelerometerData
{
    CMAccelerometerData *data = [[self motionManager] accelerometerData];
    double xyAccel = 0.0;
    double xAccel, yAccel;
    CMAcceleration accelStruct = [data acceleration];
    
    xAccel = accelStruct.x;
    yAccel = accelStruct.y;
    
    xyAccel = sqrt(pow(xAccel, 2) + pow(yAccel, 2));
    
    if (self.isUpdating) {
        NSTimeInterval delay = ACCEL_UPDATE_INTERVAL;
        [self performSelector:@selector(updateAccelerometerData) withObject:nil afterDelay:delay];
    }
    
    // add data to dataset
    NSTimeInterval timestamp = [data timestamp];
    
    if (self.dataTimeOffset == 0.0) {
        [self setDataTimeOffset:timestamp];
    }
    timestamp = timestamp - self.dataTimeOffset;
    
    NSNumber *wrappedTimestamp = [NSNumber numberWithDouble:timestamp];
    NSNumber *wrappedRawAccel = [NSNumber numberWithDouble:xyAccel];
    NSArray *stampedDatum = [NSArray arrayWithObjects:wrappedTimestamp, wrappedRawAccel, nil];
    [[self dataset] addObject:stampedDatum];
    
    if ([[self dataset] count] >= self.averagingValue) {
        int i;
        long len = [[self dataset] count];
        double sum = 0;
        
        for (i = 0; i < self.averagingValue; i++) {
            sum += [[[[self dataset] objectAtIndex:(len - i - 1)] objectAtIndex:1] doubleValue];
        }
        sum /= self.averagingValue;
        NSNumber *oldTimestamp = [[[self dataset] objectAtIndex:(len - self.averagingValue)] objectAtIndex:0];
        NSNumber *avgRawAccel = [NSNumber numberWithDouble:sum];
        NSArray *stampedAvgDatum = [NSArray arrayWithObjects:oldTimestamp, avgRawAccel, nil];
        [[self avgDataset] addObject:stampedAvgDatum];
        
        if ([self trackState] == TrackingStateNotTracking
            && sum > self.accelThreshold) {
            [self setTrackState:TrackingStateRisingPush];
        } else if ([self trackState] == TrackingStateRisingPush) {
            NSArray *arr = [self avgDataset];
            if (sum < [[[arr objectAtIndex:([arr count] - 2)] objectAtIndex:1] doubleValue]) {
                [self setTrackState:TrackingStateFallingPush];
            }
        } else if ([self trackState] == TrackingStateFallingPush) {
            NSArray *arr = [self avgDataset];
            if (sum > [[[arr objectAtIndex:([arr count] - 2)] objectAtIndex:1] doubleValue]) {
                [self setTrackState:TrackingStateRisingSlide];
                [self setLocalMinimum:sum];
            }
        } else {
            if (sum < self.accelThreshold) {
                self.lastAverage = (sum + self.localMinimum) / 2;
                double dForce = (self.lastAverage * 9.8) * .140;
                double nForce = .140 * 9.8;
                self.mu = dForce/nForce;
                [self setTrackState:TrackingStateNotTracking];
            }
        }
    }
    
    if (self.delegate) {
        [[self delegate] accelDataUpdateAvailable];
    }
}
*/

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
//    NSLog(@"Averaged %d readings", i);
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
    
//    NSLog(@"Model angles to x,y,z: %lf, %lf, %lf", rawAngleToX, rawAngleToY, rawAngleToZ);
    
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

#pragma mark - CPTScatterPlotDataSource
/*
- (double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSNumber *val;
    if (fieldEnum == CPTScatterPlotFieldX) {
        val = [[[self activeDataset] objectAtIndex: idx] objectAtIndex:0];
        return [val doubleValue];
    } else if (fieldEnum == CPTScatterPlotFieldY) {
        val = [[[self activeDataset] objectAtIndex: idx] objectAtIndex:1];
        return [val doubleValue];
    }
    else {
        return 0;
    }
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [[self activeDataset] count];
}

- (NSArray *)xAxisExtrema
{
    NSNumber *min = [[[self dataset] objectAtIndex:0] objectAtIndex:0];
    NSNumber *max = [[[self dataset] objectAtIndex:0] objectAtIndex:0];
    
    for (NSArray *pair in [self dataset]) {
        if ([[pair objectAtIndex:0] doubleValue] < [min doubleValue]) {
            min = [pair objectAtIndex:0];
        }
        if ([[pair objectAtIndex:0] doubleValue] > [max doubleValue]) {
            max = [pair objectAtIndex:0];
        }
    }
    
    return [NSArray arrayWithObjects:min, max, nil];
}

- (NSArray *)yAxisExtrema
{
    NSNumber *min = [[[self dataset] objectAtIndex:0] objectAtIndex:1];
    NSNumber *max = [[[self dataset] objectAtIndex:0] objectAtIndex:1];
    
    for (NSArray *pair in [self dataset]) {
        if ([[pair objectAtIndex:1] doubleValue] < [min doubleValue]) {
            min = [pair objectAtIndex:1];
        }
        if ([[pair objectAtIndex:1] doubleValue] > [max doubleValue]) {
            max = [pair objectAtIndex:1];
        }
    }
    
    return [NSArray arrayWithObjects:min, max, nil];
}
*/
@end
