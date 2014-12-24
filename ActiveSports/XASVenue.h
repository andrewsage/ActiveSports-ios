//
//  XASVenue.h
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XASBaseObject.h"


@interface XASVenue : XASBaseObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSNumber * locationLat;
@property (nonatomic, retain) NSNumber * locationLong;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *postCode;
@property (nonatomic, retain) NSNumber * distanceInMeters;



+ (NSMutableDictionary *) dictionary;
+ (NSString *)dictionaryPath;
+ (void)saveDictionary;

+ (XASVenue*)venueWithObjectID:(NSString*)objectID;


@end
