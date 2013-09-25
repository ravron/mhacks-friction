//
//  RAMFLevelBubbleView.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/24/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFLevelBubbleView.h"

@implementation RAMFLevelBubbleView

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctxt = UIGraphicsGetCurrentContext();
    
    NSLog(@"Contect rect: %@", NSStringFromCGRect(rect));
}

@end
