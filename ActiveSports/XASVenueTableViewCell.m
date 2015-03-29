//
//  XASVenueTableViewCell.m
//  ActiveSports
//
//  Created by Andrew Sage on 23/02/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASVenueTableViewCell.h"
#import "UIColor+Expanded.h"
#import "Constants.h"

@implementation XASVenueTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.distanceLabel.layer.cornerRadius = 5.0f;
    self.distanceLabel.clipsToBounds = YES;
    self.distanceLabel.insets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.distanceLabel.backgroundColor = [UIColor colorWithHexString:XASPositveActionColor];
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
