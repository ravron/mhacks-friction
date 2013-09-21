//
//  RAMFFirstViewController.h
//  mhacks-friction
//
//  Created by Riley Avron on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAMFAccelerometerModel.h"

@interface RAMFFirstViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *dataField;

@property RAMFAccelerometerModel * accModel;


@end
