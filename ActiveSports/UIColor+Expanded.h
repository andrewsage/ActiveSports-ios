//
//  UIColor+Expanded.h
//  ActiveSports
//
//  Created by Andrew Sage on 27/01/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Expanded)

+(UIColor *)colorWithHexString:(NSString *)hexString;
+(UIColor *)colorWithRGBHex:(uint32_t)hexValue;

@end
