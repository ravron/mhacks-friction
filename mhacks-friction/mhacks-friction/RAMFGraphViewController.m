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
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTAxis *x = axisSet.xAxis;
    CPTAxis *y = axisSet.yAxis;
    
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;

    
    graph.fill = [CPTFill fillWithColor: [CPTColor clearColor]];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"%@", [self presentingViewController]);
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
    NSArray *xExtrema = self.model.xAxisExtrema;
    NSArray *yExtrema = self.model.yAxisExtrema;
    
    NSNumber *yMin = [yExtrema objectAtIndex:0];
    NSNumber *xMax = [xExtrema objectAtIndex: 1];
    NSNumber *yMax = [yExtrema objectAtIndex: 1];
    
    
    [self.plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat([xMax doubleValue] + 1)]];
    [self.plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat([yMin doubleValue] - .25) length:CPTDecimalFromFloat(fabs([yMin doubleValue]) + fabs([yMax doubleValue]) + 0.5)]];
    [self.plot reloadData];
}


- (IBAction)sliderChanged:(UISlider *)sender {
    self.model.averagingValue = (int)sender.value;
}
@end
