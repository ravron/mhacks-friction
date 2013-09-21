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



@interface RAMFGraphViewController : UIViewController <RAMFAccelerometerModelDelegate>

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (strong, nonatomic, readonly) CPTScatterPlot *plot;

- (void)accelDataUpdateAvailable;

@end