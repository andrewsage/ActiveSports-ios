//
//  XASOpportunityTableViewCell.m
//  ActiveSports
//
//  Created by Andrew Sage on 18/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASOpportunityTableViewCell.h"
#import "UIImage+Resize.h"

@implementation XASOpportunityTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.ratingView.padding = 0.0f;
    self.ratingView.editable = NO;
    self.ratingView.starImage = [UIImage imageWithImage:[UIImage imageNamed:@"drop-listing"] scaledToSize:CGSizeMake(22.0 / 2.0, 29.0 / 2.0)];
    
    self.ratingView.backgroundColor = [UIColor clearColor];
    self.ratingView.alignment = XASRateViewAlignmentRight;
    self.ratingView.direction = XASRateViewDirectionRightToLeft;
    self.ratingView.emptyAlpha = 0.0f;
    
    
    self.distanceLabel.layer.cornerRadius = 5.0f;
    self.distanceLabel.clipsToBounds = YES;
    self.distanceLabel.insets = UIEdgeInsetsMake(20, 10, 20, 10);
    [self.distanceLabel resizeHeightToFitText];
    self.distanceLabel.backgroundColor = [UIColor colorWithRed:0.094 green:0.490 blue:0.459 alpha:1];
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
