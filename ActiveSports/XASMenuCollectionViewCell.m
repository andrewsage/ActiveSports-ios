//
//  XASMenuCollectionViewCell.m
//  ActiveSports
//
//  Created by Andrew Sage on 24/12/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASMenuCollectionViewCell.h"

@implementation XASMenuCollectionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    
    self.bottomBorderLayer = [CALayer layer];
    self.rightBorderLayer = [CALayer layer];
    
    [self.layer addSublayer:self.bottomBorderLayer];
    [self.layer addSublayer:self.rightBorderLayer];
    
    return self;
}
    


@end
