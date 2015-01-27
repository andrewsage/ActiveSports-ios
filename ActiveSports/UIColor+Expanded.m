//
//  UIColor+Expanded.m
//  ActiveSports
//
//  Created by Andrew Sage on 27/01/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "UIColor+Expanded.h"

@implementation UIColor (Expanded)

+(UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *string = hexString;
    
    // Strip off # prefix if it is present
    if ([string hasPrefix:@"#"]) {
        string = [string substringFromIndex:1];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    unsigned hexValue;
    if (![scanner scanHexInt: &hexValue]) {
        return nil;
    }
    return [UIColor colorWithRGBHex:hexValue];
}

+(UIColor *)colorWithRGBHex:(uint32_t)hexValue {
    int r = (hexValue >> 16) & 0xFF;
    int g = (hexValue >> 8) & 0xFF;
    int b = (hexValue) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

@end
