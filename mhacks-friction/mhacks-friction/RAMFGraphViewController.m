//
//  RAMFGraphViewController.m
//  mhacks-friction
//
//  Created by Van Wittekind on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFGraphViewController.h"


@interface RAMFGraphViewController ()

@property (strong, nonatomic) CPTScatterPlot *plot;
@property (nonatomic) BOOL isDrawing;

@end

@implementation RAMFGraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [[self background] setImage: [UIImage imageNamed: @"brushed_pewter.png"]];
    
    
    [super viewDidLoad];

    // Create a CPTGraph object and add to hostView
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    
    self.hostView.hostedGraph = graph;

    
    graph.fill = [CPTFill fillWithColor: [CPTColor clearColor]];
    CPTAxis *xAxis = [graph.axisSet.axes objectAtIndex:0];
    CPTAxis *yAxis = [graph.axisSet.axes objectAtIndex:1];
    NSLog(@"xAxis.axisLineStyle: %@", xAxis.axisLineStyle);
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    self.plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!
    [self.plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat( 1 )]];
    [self.plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( 10 )]];
    
    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    self.plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    
    self.model = (RAMFAccelerometerModel *)[(RAMFFirstViewController *)[self presentingViewController] getModel];
    // Set datasource
    self.plot.dataSource = self.model;
    [[(RAMFFirstViewController *)[self presentingViewController] getModel] setDelegate:self];

    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:self.plot toPlotSpace:graph.defaultPlotSpace];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"%@", [self presentingViewController]);
    [self setIsDrawing:YES];
    [self performSelector:@selector(stopDrawing) withObject:nil afterDelay:10];
}

- (void)stopDrawing
{
    [self displayMu];
    [self setIsDrawing:NO];
    [self.model setIsUpdating:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (void)accelDataUpdateAvailable
{
    if (![self isDrawing]){
        return;
    }
    NSArray *xExtrema = self.model.xAxisExtrema;
    NSArray *yExtrema = self.model.yAxisExtrema;
    
//    NSNumber *yMin = [yExtrema objectAtIndex:0];
    self.xMax = [xExtrema objectAtIndex: 1];
    self.yMax = [yExtrema objectAtIndex: 1];
    
    
    [self.plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1) length:CPTDecimalFromFloat([self.xMax doubleValue] + 1)]];
    [self.plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.6) length:CPTDecimalFromFloat(fabs([self.yMax doubleValue]) + 1.0)]];
    [self.plot reloadData];
    
    switch ([[self model] trackState]) {
        case TrackingStateNotTracking:
            [[self plot] setBackgroundColor:[[UIColor blueColor] CGColor]];
            break;
        case TrackingStateRisingPush:
            [[self plot] setBackgroundColor:[[UIColor greenColor] CGColor]];
            break;
        case TrackingStateFallingPush:
            [[self plot] setBackgroundColor:[[UIColor yellowColor] CGColor]];
            break;
        case TrackingStateRisingSlide:
            [[self plot] setBackgroundColor:[[UIColor redColor] CGColor]];
            break;
        default:
            break;
    }
    
    if([self.xMax doubleValue] >= 200){
        [[self model] setIsUpdating: NO];
    }
}


- (void) displayMu
{
    NSString *s = [NSString stringWithFormat:@"μ ≈ %lf", [self.model mu]];
    [[self muText] setText: s];
}

- (IBAction)sliderChanged:(UISlider *)sender {
    self.model.averagingValue = (int)sender.value;
}
@end
