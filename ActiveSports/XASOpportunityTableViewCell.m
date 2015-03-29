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

- (void)setOpportunity:(XASOpportunity *)opportunity {
    
    self.titleLabel.text = opportunity.name;
    self.venueLabel.text = opportunity.venue.name;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@-%@",
                           opportunity.dayOfWeek,
                           opportunity.startTime,
                           opportunity.endTime];
    self.ratingView.editable = NO;
    self.ratingView.padding = 0.0f;
    self.ratingView.rate = opportunity.effortRating.floatValue;
    
    XASVenue *venue = [XASVenue venueWithObjectID:opportunity.venue.remoteID];
    double distanceInMiles = venue.distanceInMeters.doubleValue / 1609.344;
    if(distanceInMiles > 50) {
        self.distanceLabel.text = @"> 50 miles";
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1f miles", distanceInMiles];
    }
    
    NSArray *startTimeComponents = [opportunity.startTime componentsSeparatedByString:@":"];
    NSInteger startHour = [[startTimeComponents objectAtIndex:0] integerValue];
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
    NSInteger hour = [components hour];
    
    NSDateFormatter *weekdayDateFormat = [[NSDateFormatter alloc] init];
    [weekdayDateFormat setDateFormat: @"EEEE"];
    NSString *todayName = [weekdayDateFormat stringFromDate:now];
    
    if([opportunity.dayOfWeek isEqualToString:todayName]) {
        if(startHour - hour > 2) {
            self.timeLabel.textColor = [UIColor colorWithHexString:XASNegativeActionColor];

        } else {
            self.timeLabel.textColor = [UIColor colorWithHexString:XASBrandMainColor];
        }
    } else {
        self.timeLabel.textColor = [UIColor colorWithHexString:XASBrandMainColor];
    }
}

@end
