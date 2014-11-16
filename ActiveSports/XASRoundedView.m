//
//  XASRoundedView.m
//  ActiveSports
//
//  Created by Andrew Sage on 16/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASRoundedView.h"
#import <QuartzCore/QuartzCore.h>

@implementation XASRoundedView

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.layer.cornerRadius = 5.0f;
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
