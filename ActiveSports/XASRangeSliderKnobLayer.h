//
//  XASRangeSliderKnobLayer.h
//  ActiveSports
//
//  Created by Andrew Sage on 22/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class XASRangeSlider;

@interface XASRangeSliderKnobLayer : CALayer

@property BOOL highlighted;
@property (weak) XASRangeSlider *slider;

@end
