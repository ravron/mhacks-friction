//
//  RAMFLevelBubbleView.h
//  mhacks-friction
//
//  Created by Riley Avron on 9/24/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "math.h"

@interface RAMFLevelBubbleView : UIView

- (void)setIndicatorWithAccelerationsX:(double)x Y:(double)y Z:(double)z;

@end