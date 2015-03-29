//
//  XASHeaderView.m
//  ActiveSports
//
//  Created by Andrew Sage on 28/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASHeaderView.h"

@implementation XASHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) layoutSubviews {
    [super layoutSubviews];
    
    UILabel *label = (UILabel*)[self viewWithTag:1];
    UIButton *button = (UIButton*)[self viewWithTag:2];
    //self.translatesAutoresizingMaskIntoConstraints = NO;
        
    [self removeConstraints:self.constraints];
    
    
    NSDictionary *viewsDictionary = @{@"label":label, @"button":button, @"view":self};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[label(>=50)]-20-[button(30)]-20-|"
                                            options:0
                                            metrics:nil
                                              views:viewsDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[label]-20-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-(<=1)-[button]"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    
    
    [self setNeedsUpdateConstraints];
    
    [super layoutSubviews];
}

@end
