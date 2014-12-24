//
//  XASPaddedLabel.m
//  ActiveSports
//
//  Created by Andrew Sage on 24/12/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASPaddedLabel.h"

@implementation XASPaddedLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

- (void)resizeHeightToFitText {
    CGRect frame = [self bounds];
    CGFloat textWidth = frame.size.width - (self.insets.left + self.insets.right);
    
    CGRect newSize = [self.text boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:nil];
    
    frame.size.height = newSize.size.height + self.insets.top + self.insets.bottom;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, frame.size.width, frame.size.height);
}

@end
