//
//  XASMenuCollectionViewCell.h
//  ActiveSports
//
//  Created by Andrew Sage on 24/12/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XASMenuCollectionViewCell : UICollectionViewCell

@property(nonatomic, retain) UIImage *optionImage;
@property(nonatomic, retain) UILabel *optionLabel;
@property(nonatomic, retain) CALayer *bottomBorderLayer;
@property(nonatomic, retain) CALayer *rightBorderLayer;

@end
