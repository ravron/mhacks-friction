//
//  RAMFRecordViewController.h
//  mhacks-friction
//
//  Created by Van Wittekind on 9/21/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAMFRecordViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *RecordImage;

- (void) startSpinning;

- (void) stopSpinning;

@end
