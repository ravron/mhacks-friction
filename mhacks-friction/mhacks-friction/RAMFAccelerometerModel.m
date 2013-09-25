//
//  RAMFAccelerometerModel.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFAccelerometerModel.h"

#define ACCEL_UPDATE_INTERVAL 1.0

// string constants related to notification sending
NSString *const RAMFAccNotificationDataKey = @"RAMFAccNotificationDataKey";
NSString *const RAMFNewAccDataNotification = @"RAMFNewAccDataNotification";

@interface RAMFAccelerometerModel ()

@property (nonatomic, strong) CMMotionManager *motionManager;
// accData will always hold the most recent accelerometer data
@property (nonatomic, strong) CMAccelerometerData *accData;
@property (nonatomic, strong) NSMutableArray *accDataArr;

@property (nonatomic) double accelThreshold;
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
        _accelThreshold = 0.4;
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
    
    // post notification of new data containing dictionary with data
    NSDictionary *accelerationDict = @{RAMFAccNotificationDataKey : accData};
    [[NSNotificationCenter defaultCenter] postNotificationName:RAMFNewAccDataNotification
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
