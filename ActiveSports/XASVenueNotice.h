//
//  XASVenueNotice.h
//  ActiveSports
//
//  Created by Andrew Sage on 12/12/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASBaseObject.h"
#import "XASVenue.h"


@interface XASVenueNotice : XASBaseObject

@property (nonatomic, strong) XASVenue *venue;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSDate *starts;
@property (nonatomic, strong) NSDate *expires;

+ (NSMutableDictionary *) dictionary;
+ (NSString *)dictionaryPath;
+ (void)saveDictionary;

@end
