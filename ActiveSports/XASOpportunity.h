//
//  XASOpportunity.h
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASBaseObject.h"
#import "XASVenue.h"
#import "XASActivity.h"

@interface XASOpportunity : XASBaseObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) XASVenue *venue;
@property (nonatomic, strong) XASActivity *activity;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *dayOfWeek;
@property (nonatomic, copy) NSString *opportunityDescription;
@property (nonatomic, copy) NSNumber *effortRating;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSMutableArray *tagsArray;

@property (nonatomic, retain) NSNumber * distanceInMeters;

+ (NSMutableDictionary *) dictionary;
+ (NSString *)dictionaryPath;
+ (void)saveDictionary;

- (void)rateInBackground:(NSInteger)rating withBlock:(XASBooleanResultBlock)block;
+ (NSArray*)forVenue:(XASVenue*)venue;

+ (NSArray*)forFavourites;
+ (NSArray*)forSearch:(NSDictionary *)searchDictionary;
+ (NSArray*)forTodayWithSearch:(NSDictionary *)searchDictionary;

@end
