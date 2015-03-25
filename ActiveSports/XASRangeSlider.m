//
//  XASRangeSlider.m
//  ActiveSports
//
//  Created by Andrew Sage on 22/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASRangeSlider.h"
#import "XASRangeSliderKnobLayer.h"
#import "XASRangeSliderTrackLayer.h"

@implementation XASRangeSlider {
    XASRangeSliderKnobLayer* _upperKnobLayer;
    XASRangeSliderKnobLayer* _lowerKnobLayer;
    XASRangeSliderTrackLayer *_trackLayer;
    
    float _knobWidth;
    float _useableTrackLength;
    CGPoint _previousTouchPoint;
}

#define GENERATE_SETTER(PROPERTY, TYPE, SETTER, UPDATER) \
- (void)SETTER:(TYPE)PROPERTY { \
if (_##PROPERTY != PROPERTY) { \
_##PROPERTY = PROPERTY; \
[self UPDATER]; \
} \
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {       
        [self commonSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    _trackHighlightColour = [UIColor colorWithRed:0.0 green:0.45 blue:0.94 alpha:1.0];
    _trackColour = [UIColor colorWithWhite:0.9 alpha:1.0];
    _knobColour = [UIColor greenColor];
    _curvaceousness = 1.0;
    _maximumValue = 5.0;
    _minimumValue = 1.0;
    _upperValue = 5.0;
    _lowerValue = 1.0;
    
    _trackLayer = [XASRangeSliderTrackLayer layer];
    _trackLayer.slider = self;
    [self.layer addSublayer:_trackLayer];
    
    _upperKnobLayer = [XASRangeSliderKnobLayer layer];
    _upperKnobLayer.slider = self;
    [self.layer addSublayer:_upperKnobLayer];
    
    _lowerKnobLayer = [XASRangeSliderKnobLayer layer];
    _lowerKnobLayer.slider = self;
    [self.layer addSublayer:_lowerKnobLayer];
}

- (void)layoutSubviews {
    _trackLayer.frame = CGRectInset(self.bounds, 0, (self.bounds.size.height / 2.0) - 2.0);
    
    _knobWidth = self.bounds.size.height;
    _useableTrackLength = self.bounds.size.width - _knobWidth;
    
    float upperKnobCentre = [self positionForValue:_upperValue];
    _upperKnobLayer.frame = CGRectMake(upperKnobCentre - _knobWidth / 2, 0, _knobWidth, _knobWidth);
    
    float lowerKnobCentre = [self positionForValue:_lowerValue];
    _lowerKnobLayer.frame = CGRectMake(lowerKnobCentre - _knobWidth / 2, 0, _knobWidth, _knobWidth);

}

- (float) positionForValue:(float)value
{
    return _useableTrackLength * (value - _minimumValue) /
    (_maximumValue - _minimumValue) + (_knobWidth / 2);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _previousTouchPoint = [touch locationInView:self];
    
    // hit test the knob layers
    if(CGRectContainsPoint(_lowerKnobLayer.frame, _previousTouchPoint))
    {
        _lowerKnobLayer.highlighted = YES;
        [_lowerKnobLayer setNeedsDisplay];
    }
    else if(CGRectContainsPoint(_upperKnobLayer.frame, _previousTouchPoint))
    {
        _upperKnobLayer.highlighted = YES;
        [_upperKnobLayer setNeedsDisplay];
    }
    return _upperKnobLayer.highlighted || _lowerKnobLayer.highlighted;
}

#define BOUND(VALUE, UPPER, LOWER)	MIN(MAX(VALUE, LOWER), UPPER)

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    // 1. determine by how much the user has dragged
    float delta = touchPoint.x - _previousTouchPoint.x;
    float valueDelta = (_maximumValue - _minimumValue) * delta / _useableTrackLength;
    
    _previousTouchPoint = touchPoint;
    
    // 2. update the values
    if (_lowerKnobLayer.highlighted)
    {
        _lowerValue += valueDelta;
        _lowerValue = BOUND(_lowerValue, _upperValue, _minimumValue);
    }
    if (_upperKnobLayer.highlighted)
    {
        _upperValue += valueDelta;
        _upperValue = BOUND(_upperValue, _maximumValue, _lowerValue);
    }
    
    // 3. Update the UI state
    [CATransaction begin];
    [CATransaction setDisableActions:YES] ;
    
    [self setNeedsLayout];
    [self redrawLayers];
    
    [CATransaction commit];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _lowerKnobLayer.highlighted = _upperKnobLayer.highlighted = NO;
    [self redrawLayers];
}

GENERATE_SETTER(trackHighlightColour, UIColor*, setTrackHighlightColour, redrawLayers)

GENERATE_SETTER(trackColour, UIColor*, setTrackColour, redrawLayers)

GENERATE_SETTER(curvaceousness, float, setCurvaceousness, redrawLayers)

GENERATE_SETTER(knobColour, UIColor*, setKnobColour, redrawLayers)

GENERATE_SETTER(maximumValue, float, setMaximumValue, layoutSubviews)

GENERATE_SETTER(minimumValue, float, setMinimumValue, layoutSubviews)

GENERATE_SETTER(lowerValue, float, setLowerValue, layoutSubviews)

GENERATE_SETTER(upperValue, float, setUpperValue, layoutSubviews)

- (void) redrawLayers
{
    [_upperKnobLayer setNeedsDisplay];
    [_lowerKnobLayer setNeedsDisplay];
    [_trackLayer setNeedsDisplay];
}


@end
