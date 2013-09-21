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

@interface RAMFFirstViewController : UIViewController <RAMFAccelerometerModelDelegate>

@property RAMFAccelerometerModel * accModel;

- (RAMFAccelerometerModel *) getModel;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet UIImageView *animation;

@end
