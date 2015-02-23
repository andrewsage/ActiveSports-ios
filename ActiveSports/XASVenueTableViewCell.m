//
//  XASVenueTableViewCell.m
//  ActiveSports
//
//  Created by Andrew Sage on 23/02/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASVenueTableViewCell.h"

@implementation XASVenueTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
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
