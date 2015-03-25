//
//  XASRangeSliderTrackLayer.m
//  ActiveSports
//
//  Created by Andrew Sage on 22/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASRangeSliderTrackLayer.h"
#import "XASRangeSlider.h"

@implementation XASRangeSliderTrackLayer

- (void)drawInContext:(CGContextRef)ctx {

    // clip
    float cornerRadius = self.bounds.size.height * self.slider.curvaceousness / 2.0;
    UIBezierPath *switchOutline = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                             cornerRadius:cornerRadius];
    CGContextAddPath(ctx, switchOutline.CGPath);
    CGContextClip(ctx);
    
    // fill the track
    CGContextSetFillColorWithColor(ctx, self.slider.trackColour.CGColor);
    CGContextAddPath(ctx, switchOutline.CGPath);
    CGContextFillPath(ctx);
    
    // fill the highlighed range
    CGContextSetFillColorWithColor(ctx, self.slider.trackHighlightColour.CGColor);
    float lower = [self.slider positionForValue:self.slider.lowerValue];
    float upper = [self.slider positionForValue:self.slider.upperValue];
    CGContextFillRect(ctx, CGRectMake(lower, 0, upper - lower, self.bounds.size.height));
}

@end
