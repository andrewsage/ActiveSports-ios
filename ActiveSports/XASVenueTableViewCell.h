//
//  XASVenueTableViewCell.h
//  ActiveSports
//
//  Created by Andrew Sage on 23/02/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XASPaddedLabel.h"

@interface XASVenueTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet XASPaddedLabel *distanceLabel;

@end
