//
//  XASRangeSlider.h
//  ActiveSports
//
//  Created by Andrew Sage on 22/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XASRangeSlider : UIControl

@property (nonatomic) float maximumValue;
@property (nonatomic) float minimumValue;
@property (nonatomic) float upperValue;
@property (nonatomic) float lowerValue;

@property (nonatomic) UIColor* trackColour;
@property (nonatomic) UIColor* trackHighlightColour;
@property (nonatomic) UIColor* knobColour;
@property (nonatomic) float curvaceousness;

- (float) positionForValue:(float)value;

@end
