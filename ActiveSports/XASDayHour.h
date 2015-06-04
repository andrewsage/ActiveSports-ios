//
//  XASDayHour.h
//  ActiveSports
//
//  Created by Andrew Sage on 29/05/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XASDayHour : NSObject <NSCopying>

@property (nonatomic, copy) NSNumber *dayOfWeek;
@property (nonatomic, copy) NSNumber *hourOfDay;

- (NSString*)asString;

@end
