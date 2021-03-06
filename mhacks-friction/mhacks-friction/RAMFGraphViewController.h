//
//  RAMFGraphViewController.h
//  mhacks-friction
//
//  Created by Van Wittekind on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "RAMFFirstViewController.h"
#import "RAMFAccelerometerModelDelegate.h"
#import "RAMFAccelerometerModel.h"


@interface RAMFGraphViewController : UIViewController <RAMFAccelerometerModelDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *background;

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (strong, nonatomic, readonly) CPTScatterPlot *plot;

@property NSNumber *xMax;

@property NSNumber *xMin;

@property NSNumber *yMax;

@property NSNumber *yMin;

- (void)accelDataUpdateAvailable;

- (void) displayMu;

@property CPTXYPlotSpace *plotSpace;

@property CPTPlotRange *xRange;

@property CPTPlotRange *yRange;

@property (weak, nonatomic) IBOutlet UILabel *muText;

@property RAMFAccelerometerModel *model;
- (IBAction)sliderChanged:(UISlider *)sender;

@end