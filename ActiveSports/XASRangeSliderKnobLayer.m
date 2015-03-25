//
//  XASRangeSliderKnobLayer.m
//  ActiveSports
//
//  Created by Andrew Sage on 22/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASRangeSliderKnobLayer.h"
#import "XASRangeSlider.h"

@implementation XASRangeSliderKnobLayer

- (void)drawInContext:(CGContextRef)ctx {
    CGRect knobFrame = CGRectInset(self.bounds, 2.0, 2.0);
    
    UIBezierPath *knobPath = [UIBezierPath bezierPathWithRoundedRect:knobFrame
                                                        cornerRadius:knobFrame.size.height * self.slider.curvaceousness / 2.0];
    // fill
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddPath(ctx, knobPath.CGPath);
    CGContextFillPath(ctx);
    
    // outline
    CGContextSetStrokeColorWithColor(ctx, self.slider.knobColour.CGColor);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextAddPath(ctx, knobPath.CGPath);
    CGContextStrokePath(ctx);
    
    if (self.highlighted) {
        // fill
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.0 alpha:0.1].CGColor);
        CGContextAddPath(ctx, knobPath.CGPath);
        CGContextFillPath(ctx);
    }
}

@end
