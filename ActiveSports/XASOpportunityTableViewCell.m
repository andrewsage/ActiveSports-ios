//
//  XASOpportunityTableViewCell.m
//  ActiveSports
//
//  Created by Andrew Sage on 18/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASOpportunityTableViewCell.h"
#import "UIImage+Resize.h"
#import "UIColor+Expanded.h"
#import "Constants.h"

@implementation XASOpportunityTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.ratingView.padding = 0.0f;
    self.ratingView.editable = NO;
    self.ratingView.starImage = [UIImage imageNamed:@"listing-exertion"];
    
    self.ratingView.backgroundColor = [UIColor clearColor];
    self.ratingView.alignment = XASRateViewAlignmentRight;
    self.ratingView.direction = XASRateViewDirectionRightToLeft;
    self.ratingView.emptyAlpha = 0.0f;
    
    self.distanceLabel.layer.cornerRadius = 5.0f;
    self.distanceLabel.clipsToBounds = YES;
    self.distanceLabel.insets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.distanceLabel.backgroundColor = [UIColor colorWithHexString:XASPositveActionColor];
    
    self.backgroundColor = [UIColor whiteColor];
    self.favouriteImageView.image = [UIImage imageNamed:@"favourite-activity"];
    
    // Set the constraints in code
    //[self removeConstraints:self.constraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
