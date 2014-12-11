//
//  XASOpportunityTableViewCell.m
//  ActiveSports
//
//  Created by Andrew Sage on 18/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASOpportunityTableViewCell.h"

@implementation XASOpportunityTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.ratingView.padding = 0.0f;
    self.ratingView.editable = NO;
    self.ratingView.starImage = [UIImage imageNamed:@"drop-rating-small"];
    self.ratingView.backgroundColor = [UIColor clearColor];
    self.ratingView.alignment = XASRateViewAlignmentRight;
    self.ratingView.direction = XASRateViewDirectionRightToLeft;
    self.ratingView.emptyAlpha = 0.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
