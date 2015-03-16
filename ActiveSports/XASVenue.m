//
//  XASVenue.m
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASVenue.h"
#import "XASVenueNotice.h"

@implementation XASVenue

+ (NSString *)szClassName {
    return @"Venue";
}

+ (NSMutableDictionary *)dictionary {
    static NSMutableDictionary *objects = nil;
    
    if (objects == nil)
    {
        NSString *path = [self dictionaryPath];
        
        objects = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if(objects == nil) {
            objects = [NSMutableDictionary dictionary];
        }
    }
    
    return objects;
}

+ (NSString *)dictionaryPath {
    NSString *documentsDir = [XASBaseObject cacheDirectory];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[XASVenue szClassName], @"123"]];
    return path;
}

+ (void) saveDictionary {
    NSMutableDictionary *dictionary = [XASVenue dictionary];
    if([NSKeyedArchiver archiveRootObject:dictionary toFile:[XASVenue dictionaryPath]]) {
    } else {
        NSLog(@"Failed to save dictionary");
    }
}

+ (NSMutableArray*)arrayFromJSONArray:(NSArray *)jsonArray {
    NSMutableArray *objectsArray = [NSMutableArray array];
    NSMutableDictionary *dictionary = [XASVenue dictionary];

    
    for(NSDictionary *objectDictionary in jsonArray) {
        XASVenue *object = [[XASVenue alloc] initWithDictionary:objectDictionary];
        [dictionary setObject:object forKey:object.remoteID];
        
        [objectsArray addObject:object];
    }
    [XASVenue saveDictionary];

    return objectsArray;
}




+ (void)fetchAllInBackgroundWithBlock:(XASArrayResultBlock)block {
    
    NSString *command = @"venues.json";
    
    [self sendRequestToServer:command block:block];
}

+ (void)fetchAllInBackgroundFor:(XASBaseObject*)object withBlock:(XASArrayResultBlock)block {
    NSString *command = [NSString stringWithFormat:@"regions/%@/venues.json", object.remoteID];
    
    [self sendRequestToServer:command block:block];
}


- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_locationLat forKey:@"lat"];
    [encoder encodeObject:_locationLong forKey:@"long"];
    [encoder encodeObject:_address forKey:@"address"];
    [encoder encodeObject:_postCode forKey:@"postCode"];
    [encoder encodeObject:_phone forKey:@"phone"];
    [encoder encodeObject:_website forKey:@"website"];
    [encoder encodeObject:_slug forKey:@"slug"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self=[super initWithCoder:decoder])) {
        _name = [decoder decodeObjectForKey:@"name"];
        _locationLat = [decoder decodeObjectForKey:@"lat"];
        _locationLong = [decoder decodeObjectForKey:@"long"];
        _address = [decoder decodeObjectForKey:@"address"];
        _postCode = [decoder decodeObjectForKey:@"postCode"];
        _phone = [decoder decodeObjectForKey:@"phone"];
        _website = [decoder decodeObjectForKey:@"website"];
        _slug = [decoder decodeObjectForKey:@"slug"];
    }
    return self;
}



- (id)initWithDictionary:(NSDictionary*)objectDictionary {
    self = [super initWithDictionary:objectDictionary];
    
    if(self) {
        [self updateInformation:objectDictionary];
    }
    
    return self;
}

- (void)updateInformation:(NSDictionary *)objectDictionary {
    [super updateInformation:objectDictionary];
    
    self.name = [objectDictionary valueForKey:@"name"];
    self.address = [objectDictionary valueForKey:@"address"];
    self.postCode = [objectDictionary valueForKey:@"postcode"];
    self.phone = [objectDictionary valueForKey:@"telephone"];
    self.website = [objectDictionary valueForKey:@"web"];
    self.slug = [objectDictionary valueForKey:@"slug"];
    
    NSLog(@"updating %@", self.name);
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * latNumber = [f numberFromString:[objectDictionary valueForKey:@"latitude"]];
    
    NSNumber * longNumber = [f numberFromString:[objectDictionary valueForKey:@"longitude"]];
    
    self.locationLat = latNumber;
    self.locationLong = longNumber;
    
    NSArray *venueNoticesArray = [objectDictionary objectForKey:@"venue_notices"];
    if(venueNoticesArray) {
        for(NSDictionary *venueNoticeDictionary in venueNoticesArray) {
            XASVenueNotice *venueNotice = [[XASVenueNotice alloc] initWithDictionary:venueNoticeDictionary];
            venueNotice.venue = self;
            [[XASVenueNotice dictionary] setObject:venueNotice forKey:venueNotice.remoteID];
            [XASVenueNotice saveDictionary];
        }
        
    }
}

+ (XASVenue*)venueWithObjectID:(NSNumber*)objectID {
    
    XASVenue *matchingVenue = nil;
    
    NSDictionary *dictionary = [XASVenue dictionary];
    for(NSString *key in dictionary.allKeys) {
        XASVenue *venue = [dictionary objectForKey:key];
        
        if([venue.remoteID isEqual:objectID]) {
            matchingVenue = venue;
            break;
        }
    }
    
    return matchingVenue;
}

@end
