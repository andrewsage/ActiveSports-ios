//
//  XASVenueOwner.h
//  ActiveSports
//
//  Created by Andrew Sage on 24/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASBaseObject.h"

@interface XASVenueOwner : XASBaseObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSNumber * locationLat;
@property (nonatomic, retain) NSNumber * locationLong;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *postCode;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, copy) NSString *slug;

+ (NSMutableDictionary *) dictionary;
+ (NSString *)dictionaryPath;
+ (void)saveDictionary;

@end
