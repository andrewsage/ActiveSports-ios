//
//  XASPreferenceTableViewCell.h
//  ActiveSports
//
//  Created by Andrew Sage on 24/12/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XASPreferenceTableViewCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noImageView;
@property (weak, nonatomic) IBOutlet UIImageView *yesImageView;


@end
