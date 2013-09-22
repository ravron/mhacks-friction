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
#import "RAMFMagnetometerModel.h"

@interface RAMFFirstViewController : UIViewController <RAMFAccelerometerModelDelegate>

@property (strong, nonatomic) RAMFAccelerometerModel *accModel;
@property (strong, nonatomic) RAMFMagnetometerModel *magModel;

- (RAMFAccelerometerModel *) getModel;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet UIImageView *animation;

@end
