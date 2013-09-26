//
//  RAMFLevelBubbleView.m
//  mhacks-friction
//
//  Created by Riley Avron on 9/24/13.
//  Copyright (c) 2013 Riley Avron. All rights reserved.
//

#import "RAMFLevelBubbleView.h"

// convenience macro for rad to deg
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
// SENSITIVITY_MULTIPLIER changes the bounding range of the indicator's
// position.  When SENSITIVITY_MULTIPLIER == 1, the indicator will hit
// the "walls" at +/- 90 degress; when it == 4, the indicator will peg
// out at +/- 22.5 degrees (90 / 4)
#define SENSITIVITY_MULTIPLIER 4

@interface RAMFLevelBubbleView ()

// X and Y of this CGPoint range from -1 to 1, with the extrema indicating
// the farthest that the indicator circle may move in the given
// direction
@property (nonatomic) CGPoint indicatorOffset;

@end

@implementation RAMFLevelBubbleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _indicatorOffset.x = _indicatorOffset.y = 0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // SETUP
    
    // width, color of enclosing circle
    CGFloat outerEllipseWidth = 4.0;
    CGColorRef outerEllipseColor = [[UIColor colorWithWhite:0.75 alpha:1] CGColor];
    
    // ratio of moving dot diameter to size of view, color of dot
    CGFloat indicatorSizeRatio = 0.5;
    CGColorRef indicatorColor = [[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1] CGColor];
    // minimum distance to maintain between moving dot and enclosing circle
    // as ratio of standoff distance to dot diameter
    CGFloat indicatorStandoffRatio = 0.05;
    
    
    // DRAWING
    
    // enclosing circle drawing
    CGRect ellipseRect = CGRectInset(rect, outerEllipseWidth / 2.0,
                                     outerEllipseWidth / 2.0);
    CGContextSetLineWidth(c, outerEllipseWidth);
    CGContextSetStrokeColorWithColor(c, outerEllipseColor);
    CGContextStrokeEllipseInRect(c, ellipseRect);
    
    // orientation dot in upper-left corner, temporary
    CGRect idRect = CGRectMake(rect.origin.x + outerEllipseWidth / 2,
                               rect.origin.y + outerEllipseWidth / 2, 10, 10);
    CGContextStrokeRect(c, idRect);
    
    // calculate indicator rect size
    CGRect indicatorRect;
    indicatorRect.size.height = indicatorSizeRatio * rect.size.height;
    indicatorRect.size.width  = indicatorSizeRatio * rect.size.width;
    
    // calculate actual minimum offset of indicator from enclosing circle
    // in unlikely case that height and width are different, use the lesser
    CGFloat indicatorStandoff;
    if (indicatorRect.size.height <= indicatorRect.size.width)
        indicatorStandoff = indicatorRect.size.height * indicatorStandoffRatio;
    else
        indicatorStandoff = indicatorRect.size.width * indicatorStandoffRatio;
    
    // calculate maximum allowable X and Y offsets to apply to the
    // indicatorRect's origin
    CGFloat indicatorMaxXOffset = (ellipseRect.size.width - outerEllipseWidth - indicatorRect.size.width) / 2 - indicatorStandoff;
    CGFloat indicatorMaxYOffset = (ellipseRect.size.height - outerEllipseWidth - indicatorRect.size.height) / 2 - indicatorStandoff;
    
    // calculate indicatorRect's position
    indicatorRect.origin.x = CGRectGetMidX(rect) - indicatorRect.size.width / 2 + ([self indicatorOffset].x * indicatorMaxXOffset);
    indicatorRect.origin.y = CGRectGetMidY(rect) - indicatorRect.size.height / 2 + ([self indicatorOffset].y * indicatorMaxYOffset);
    
    // draw indicator
    CGContextSetFillColorWithColor(c, indicatorColor);
    CGContextFillEllipseInRect(c, indicatorRect);
}

- (void)setIndicatorWithAccelerationsX:(double)x Y:(double)y Z:(double)z
{
    // variables that will ultimately be put into the indicator offset
    CGPoint newPoint;
    
    // magnitude of indicator vector, should always be in range [-1,1]
    double magnitude = 0.0;
    
    // current orientation of the interface, to modifiy x, y values
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // magnitude is vector sum magnitude of x and y
    x *= SENSITIVITY_MULTIPLIER;
    y *= SENSITIVITY_MULTIPLIER;
    magnitude = sqrt(pow(x,2) + pow(y, 2));
    
    // bounds check
    if (magnitude > 1.0) {
        x = x * (1 / magnitude);
        y = y * (1 / magnitude);
        magnitude = 1.0;
    }
    
    if (z < 0) {
        // meaning, roughly, the phone is more face-up than face-down
        
        // flip sign to match screen coords
        newPoint.x = -x;
        newPoint.y = y;
    } else {
        // the phone is more face-down than face-up
        if (magnitude < 1.0) {
            x = x * (1 / magnitude);
            y = y * (1 / magnitude);
            magnitude = 1.0;
        }
        newPoint.x = -x;
        newPoint.y = y;
    }
    
    CGFloat temp = 0.0;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            // do nothing
            break;
        case UIInterfaceOrientationLandscapeLeft:
            temp = newPoint.x;
            newPoint.x = -newPoint.y;
            newPoint.y = temp;
            break;
        case UIInterfaceOrientationLandscapeRight:
            temp = newPoint.x;
            newPoint.x = newPoint.y;
            newPoint.y = -temp;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            newPoint.x *= -1;
            newPoint.y *= -1;
            break;
    }
    
    [self setIndicatorOffset:newPoint];
    [self setNeedsDisplay];
}

- (void)dealloc
{
    NSLog(@"Dealloc of bubble view");
}

@end