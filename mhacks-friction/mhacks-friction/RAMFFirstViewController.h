//
//  RAMFFirstViewController.h
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAMFAccelerometerModel.h"
#import "CorePlot-CocoaTouch.h"
#import "RAMFDeviceMotionModel.h"
#import "RAMFRecordViewController.h"

@interface RAMFFirstViewController : UIViewController <RAMFAccelerometerModelDelegate, RAMFDeviceMotionModelDelegate>

@property (strong, nonatomic) RAMFAccelerometerModel *accModel;
@property (strong, nonatomic) RAMFDeviceMotionModel *devMotionModel;

@property (strong, nonatomic) RAMFRecordViewController *recordView;

- (RAMFAccelerometerModel *) getModel;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet UIImageView *animation;

@end