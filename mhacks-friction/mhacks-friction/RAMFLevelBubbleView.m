//
//  RAMFLevelBubbleView.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/24/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFLevelBubbleView.h"

@implementation RAMFLevelBubbleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        NSLog(@"init with coder");
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGFloat outerEllipseWidth = 4.0;
    CGColorRef outerEllipseColor = [[UIColor colorWithWhite:0.75 alpha:1] CGColor];
    
    CGRect ellipseRect = CGRectInset(rect, outerEllipseWidth / 2.0, outerEllipseWidth / 2.0);
    
    CGContextSetLineWidth(c, outerEllipseWidth);
    CGContextSetStrokeColorWithColor(c, outerEllipseColor);
    CGContextStrokeEllipseInRect(c, ellipseRect);
    
    CGRect idRect = CGRectMake(rect.origin.x, rect.origin.y, 10, 10);
    CGContextStrokeRect(c, idRect);
}

- (void)dealloc
{
    NSLog(@"Dealloc of bubble view");
}

@end
