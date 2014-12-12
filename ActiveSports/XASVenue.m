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
    
    for(NSDictionary *objectDictionary in jsonArray) {
        XASVenue *venue = [[XASVenue alloc] init];
        
        [venue updateBasicInformation:objectDictionary];
        
        venue.name = [objectDictionary objectForKey:@"name"];
        
        [objectsArray addObject:venue];
    }
    
    return objectsArray;
}


+ (void)fetchAllInBackgroundWithBlock:(XASArrayResultBlock)block {
    
    NSString *command = @"venues.json";
    
    [self sendRequestToServer:command block:block];
}


- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_locationLat forKey:@"lat"];
    [encoder encodeObject:_locationLong forKey:@"long"];
    [encoder encodeObject:_address forKey:@"address"];
    [encoder encodeObject:_postCode forKey:@"postCode"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self=[super initWithCoder:decoder])) {
        _name = [decoder decodeObjectForKey:@"name"];
        _locationLat = [decoder decodeObjectForKey:@"lat"];
        _locationLong = [decoder decodeObjectForKey:@"long"];
        _address = [decoder decodeObjectForKey:@"address"];
        _postCode = [decoder decodeObjectForKey:@"postCode"];
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


@end
