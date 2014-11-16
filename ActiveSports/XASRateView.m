//
//  XASRateView.m
//  ActiveSports
//
//  Created by Andrew Sage on 16/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASRateView.h"

static NSString *defaulStarImageFilename = @"drop.png";

@interface XASRateView ()

- (void)commonSetup;
- (void)handleTouchAtLocation:(CGPoint)location;
- (void)notifyDelegate;

@end

@implementation XASRateView

- (XASRateView *)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame star:[UIImage imageNamed:defaulStarImageFilename]];
}

- (XASRateView *)initWithFrame:(CGRect)frame star:(UIImage *)starImage {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _starImage = starImage;
        
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        _starImage = [UIImage imageNamed:defaulStarImageFilename];
        
        [self commonSetup];
    }
    return self;
}

// Setup common to both initWithFrame and initWithCoder
- (void)commonSetup {
    _padding = 4;
    _numOfStars = 5;
    self.alignment = XASRateViewAlignmentLeft;
    self.editable = NO;
}

- (void)drawRect:(CGRect)rect {
    switch (_alignment) {
        case XASRateViewAlignmentLeft:
        {
            _origin = CGPointMake(0, 0);
            break;
        }
        case XASRateViewAlignmentCenter:
        {
            _origin = CGPointMake((self.bounds.size.width - _numOfStars * _starImage.size.width - (_numOfStars - 1) * _padding)/2, 0);
            break;
        }
        case XASRateViewAlignmentRight:
        {
            _origin = CGPointMake(self.bounds.size.width - _numOfStars * _starImage.size.width - (_numOfStars - 1) * _padding, 0);
            break;
        }
    }
    
    float x = _origin.x;
    for(int i = 0; i < _numOfStars; i++) {
        [_starImage drawAtPoint:CGPointMake(x, _origin.y) blendMode:kCGBlendModeNormal alpha:0.5f];
        x += _starImage.size.width + _padding;
    }
    
    
    float floor = floorf(_rate);
    x = _origin.x;
    for (int i = 0; i < floor; i++) {
        [_starImage drawAtPoint:CGPointMake(x, _origin.y)];
        x += _starImage.size.width + _padding;
    }
    
    if (_numOfStars - floor > 0.01) {
        UIRectClip(CGRectMake(x, _origin.y, _starImage.size.width * (_rate - floor), _starImage.size.height));
        [_starImage drawAtPoint:CGPointMake(x, _origin.y)];
    }
}

- (void)setRate:(CGFloat)rate {
    _rate = rate;
    [self setNeedsDisplay];
    [self notifyDelegate];
}

- (void)setAlignment:(XASRateViewAlignment)alignment {
    _alignment = alignment;
    [self setNeedsLayout];
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    self.userInteractionEnabled = _editable;
}

- (void)setStarImage:(UIImage *)starImage
{
    if (starImage != _starImage) {
        _starImage = starImage;
        [self setNeedsDisplay];
    }
}


- (void)handleTouchAtLocation:(CGPoint)location {
    
    for(NSInteger i = _numOfStars - 1; i > -1; i--) {
        if (location.x > _origin.x + i * (_starImage.size.width + _padding) - _padding / 2.) {
            self.rate = i + 1;
            return;
        }
    }
    self.rate = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)notifyDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rateView:changedToNewRate:)]) {
        [self.delegate performSelector:@selector(rateView:changedToNewRate:)
                            withObject:self withObject:[NSNumber numberWithFloat:self.rate]];
    }
}

@end
