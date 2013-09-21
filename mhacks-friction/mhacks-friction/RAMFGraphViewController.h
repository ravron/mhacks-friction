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



@interface RAMFGraphViewController : UIViewController

- (IBAction)backButton:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;

@end