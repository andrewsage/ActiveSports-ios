//
//  XASRateView.h
//  ActiveSports
//
//  Created by Andrew Sage on 16/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XASRateViewDelegate;
typedef enum {
    XASRateViewAlignmentLeft,
    XASRateViewAlignmentCenter,
    XASRateViewAlignmentRight
} XASRateViewAlignment;


@interface XASRateView : UIView {
    CGPoint _origin;
    NSInteger _numOfStars;
}

@property(nonatomic, assign) XASRateViewAlignment alignment;
@property(nonatomic, assign) CGFloat rate;
@property(nonatomic, assign) CGFloat padding;
@property(nonatomic, assign) BOOL editable;
@property(nonatomic, retain) UIImage *starImage;
@property(nonatomic, assign) NSObject<XASRateViewDelegate> *delegate;

- (XASRateView *)initWithFrame:(CGRect)frame;
- (XASRateView *)initWithFrame:(CGRect)frame star:(UIImage *)starImage;

@end

@protocol XASRateViewDelegate

- (void)rateView:(XASRateView *)rateView changedToNewRate:(NSNumber *)rate;

@end