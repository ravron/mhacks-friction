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
@property (nonatomic) CMAccelerometerData *accelData;
@property double rawAccel;

@property (nonatomic) NSMutableArray *dataset;

@property (nonatomic) NSTimeInterval dataTimeOffset;

@end

@implementation RAMFAccelerometerModel

- (id)init
{
    self = [super init];
    
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        _dataset = [NSMutableArray array];
        _isUpdating = NO;
    }
    
    return self;
}

- (void)updateAccelerometerData
{
    [self setAccelData:[[self motionManager] accelerometerData]];
    double xyAccel = 0.0;
    double xAccel, yAccel;
    CMAcceleration accelStruct = [[self accelData] acceleration];

    xAccel = accelStruct.x;
    yAccel = accelStruct.y;
    
    xyAccel = sqrt(pow(xAccel, 2) + pow(yAccel, 2));
    [self setRawAccel:xyAccel];
    
    if (self.isUpdating) {
        NSTimeInterval delay = 0.1;
        [self performSelector:@selector(updateAccelerometerData) withObject:nil afterDelay:delay];
    }
    
//    [self logAccelData];
    // add data to dataset
    
    NSTimeInterval timestamp = [[self accelData] timestamp];
    
    if (self.dataTimeOffset == 0.0) {
        [self setDataTimeOffset:timestamp];
    }
    timestamp = timestamp - self.dataTimeOffset;
    
    NSNumber *wrappedTimestamp = [NSNumber numberWithDouble:timestamp];
    NSNumber *wrappedRawAccel = [NSNumber numberWithDouble:self.rawAccel];
    NSArray *stampedDatum = [NSArray arrayWithObjects:wrappedTimestamp, wrappedRawAccel, nil];
    [[self dataset] addObject:stampedDatum];
    
    if (self.delegate) {
        [[self delegate] accelDataUpdateAvailable];
    }
}

- (void)logAccelData
{
    NSLog(@"%lf", [self rawAccel]);
}

- (void)setIsUpdating:(BOOL)isUpdating
{
    if (isUpdating == _isUpdating)
        return;
    
    if (isUpdating && !_isUpdating) {
        _isUpdating = isUpdating;
        [[self dataset] removeAllObjects];
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

#pragma mark - CPTScatterPlotDataSource

/*
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    int x = idx - 4;
    if (fieldEnum == CPTScatterPlotFieldX) {
        return [NSNumber numberWithInt:x];
    } else {
        return [NSNumber numberWithInt:x * x];
    }
}
*/

- (double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSNumber *val;
    if (fieldEnum == CPTScatterPlotFieldX) {
        val = [[[self dataset] objectAtIndex: idx] objectAtIndex:0];
        return [val doubleValue];
    } else if (fieldEnum == CPTScatterPlotFieldY) {
        val = [[[self dataset] objectAtIndex: idx] objectAtIndex:1];
        return [val doubleValue];
    }
    else {
        return 0;
    }
}


- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [[self dataset] count];
}
/*
- (NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
#warning "fix this"
    
    NSLog(@"Asked for range starting at %d, length %d", indexRange.location, indexRange.length);
    NSLog(@"Asked for field enum %d", fieldEnum);
    
    NSArray *
    
    NSMutableArray *mutableRetArray = [NSMutableArray array];
    
    long int index = 0;
    for (NSArray *pair in self.dataset) {
        if (index >= indexRange.location && index < indexRange.location + indexRange.length) {
            [mutableRetArray addObject:[pair objectAtIndex:fieldEnum]];
        }
        index++;
    }
    
    NSArray *retArray = [NSArray arrayWithArray:mutableRetArray];
    return retArray;
}
*/
@end
