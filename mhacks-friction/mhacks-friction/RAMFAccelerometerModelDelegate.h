//
//  RAMFAccelerometerModelDelegate.h
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RAMFAccelerometerModelDelegate <NSObject>

- (void)accelDataUpdateAvailable;

@end
