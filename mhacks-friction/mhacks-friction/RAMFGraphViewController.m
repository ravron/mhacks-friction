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
    [super viewDidLoad];

    // Create a CPTGraph object and add to hostView
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    
    self.hostView.hostedGraph = graph;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTAxis *x = axisSet.xAxis;
    CPTAxis *y = axisSet.yAxis;
    
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;

    
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    self.plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!
    [self.plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( -5 ) length:CPTDecimalFromFloat( 10 )]];
    [self.plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( 20 )]];
    
    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    self.plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    // Set datasource
    self.plot.dataSource = [(RAMFFirstViewController *)[self presentingViewController] getModel];
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

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return 9; // Our sample graph contains 9 'points'
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)accelDataUpdateAvailable
{
//    self.xMax++;
//    self.yMax++;
    
    [self.plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( xMax + 1 )]];
    [self.plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( yMax + 1 )]];
    [self.plot reloadData];
}


@end
