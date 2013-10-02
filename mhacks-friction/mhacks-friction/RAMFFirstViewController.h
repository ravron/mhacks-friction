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
#import "RAMFLevelBubbleView.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface RAMFFirstViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) RAMFAccelerometerModel *accModel;

- (RAMFAccelerometerModel *) getModel;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *animation;
@property (weak, nonatomic) IBOutlet RAMFLevelBubbleView *bubbleView;

- (IBAction)testButtonPressed;

@end