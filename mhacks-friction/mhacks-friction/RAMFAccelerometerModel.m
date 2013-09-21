//
//  RAMFAccelerometerModel.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFAccelerometerModel.h"

@interface RAMFAccelerometerModel ()

@property (nonatomic) CMMotionManager *motionManager;

@property (nonatomic, strong) NSMutableArray *dataset;
@property (nonatomic, strong) NSMutableArray *avgDataset;
@property (nonatomic, strong) NSMutableArray *activeDataset;

@property (nonatomic) NSTimeInterval dataTimeOffset;

@end

@implementation RAMFAccelerometerModel

- (id)init
{
    self = [super init];
    
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        _dataset = [NSMutableArray array];
        _avgDataset = [NSMutableArray array];
        _activeDataset = _dataset;
        _isUpdating = NO;
        _shouldAverage = NO;
        _averagingValue = 6;
    }
    
    return self;
}

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
        NSTimeInterval delay = 0.05;
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
    }
    if (self.delegate) {
        [[self delegate] accelDataUpdateAvailable];
    }
}

- (void)setIsUpdating:(BOOL)isUpdating
{
    if (isUpdating == _isUpdating)
        return;
    
    if (isUpdating && !_isUpdating) {
        _isUpdating = isUpdating;
        [[self dataset] removeAllObjects];
        [[self avgDataset] removeAllObjects];
        [[self motionManager] startAccelerometerUpdates];
        [self setDataTimeOffset:0];
        [self updateAccelerometerData];
    } else {
        [[self motionManager] stopAccelerometerUpdates];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    
    _isUpdating = isUpdating;
}

- (BOOL)isUpdating
{
    return _isUpdating;
}

- (void)setShouldAverage:(BOOL)shouldAverage
{
    if (shouldAverage) {
        self.activeDataset = self.avgDataset;
    } else {
        self.activeDataset = self.dataset;
    }
    _shouldAverage = shouldAverage;
}

#pragma mark - CPTScatterPlotDataSource

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

@end
