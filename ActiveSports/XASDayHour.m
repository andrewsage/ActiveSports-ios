//
//  XASDayHour.m
//  ActiveSports
//
//  Created by Andrew Sage on 29/05/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASDayHour.h"

@implementation XASDayHour

- (id)copyWithZone:(NSZone *)zone {
    
    id copy = [[[self class] alloc] init];
    if(copy) {
        [copy setHourOfDay:[self.hourOfDay copyWithZone:zone]];
        [copy setDayOfWeek:[self.dayOfWeek copyWithZone:zone]];
    }
    
    return copy;
}

- (BOOL)isEqual:(id)object {
    
    if(self == object) {
        return YES;
    }
    
    if(![object isKindOfClass:[XASDayHour class]]) {
        return NO;
    }
    
    XASDayHour *other = (XASDayHour*)object;
    
    //return [self.asString isEqualToString:other.asString];
    return self.hourOfDay.integerValue == other.hourOfDay.integerValue && self.dayOfWeek.integerValue == other.dayOfWeek.integerValue;
}

- (NSString*)asString {
    
    NSString *string;
    NSArray *days = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    
    string = [NSString stringWithFormat:@"%@ %02ld:00", days[self.dayOfWeek.integerValue], (long)self.hourOfDay.integerValue];
    
    return string;
}

@end
