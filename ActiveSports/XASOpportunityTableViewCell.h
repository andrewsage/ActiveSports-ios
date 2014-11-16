//
//  XASOpportunityTableViewCell.h
//  ActiveSports
//
//  Created by Andrew Sage on 18/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XASRateView.h"

@interface XASOpportunityTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet XASRateView *ratingView;


@end
