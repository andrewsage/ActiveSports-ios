//
//  XASRateViewController.h
//  ActiveSports
//
//  Created by Andrew Sage on 07/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XASOpportunity.h"


@interface XASRateViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *effortIconView1;
@property (weak, nonatomic) IBOutlet UIImageView *effortIconView2;
@property (weak, nonatomic) IBOutlet UIImageView *effortIconView3;
@property (weak, nonatomic) IBOutlet UIImageView *effortIconView4;
@property (weak, nonatomic) IBOutlet UIImageView *effortIconView5;
@property (weak, nonatomic) IBOutlet UILabel *opportunityNameLabel;


@property (nonatomic, strong) XASOpportunity *opportunity;

@end
