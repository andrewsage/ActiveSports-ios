//
//  XASProgressView.m
//  ActiveSports
//
//  Created by Andrew Sage on 24/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASProgressView.h"

@interface XASProgressView () {
    
}

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSLayoutConstraint *progressWidthConstraint;


@end
@implementation XASProgressView

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupView];
}


#pragma mark - IB Live Rendering Preparation

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    [self setupView];
}


#pragma mark - Setup Methods

- (void)setupView {
    
    _percentage = 0.0;
    
    
    self.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.alpha = 0.5;
    
    [self addSubview:self.backgroundView];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:0.0]];
    

    
    self.progressView = [[UIView alloc] initWithFrame:CGRectZero];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.progressView];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    self.progressWidthConstraint = [NSLayoutConstraint constraintWithItem:self.progressView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeWidth
                                                              multiplier:self.percentage
                                                                 constant:0.0];
    [self addConstraint:self.progressWidthConstraint];

    self.progressView.layer.cornerRadius = 5.0f;
    self.progressView.layer.masksToBounds = YES;
    
    self.backgroundView.layer.cornerRadius = 5.0f;
    self.backgroundView.layer.masksToBounds = YES;
}

- (void)setPercentage:(CGFloat)percentage {
    
    _percentage = percentage / 100.0f;
    [self removeConstraint:self.progressWidthConstraint];
    self.progressWidthConstraint = [NSLayoutConstraint constraintWithItem:self.progressView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:self.percentage
                                                                 constant:0.0];
    [self addConstraint:self.progressWidthConstraint];
    [self layoutIfNeeded];
}

@end
