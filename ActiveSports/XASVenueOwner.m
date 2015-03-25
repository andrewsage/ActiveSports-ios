//
//  XASVenueOwner.m
//  ActiveSports
//
//  Created by Andrew Sage on 24/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASVenueOwner.h"

@implementation XASVenueOwner

+ (NSString *)szClassName {
    return @"VenueOwner";
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
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[XASVenueOwner szClassName], @"123"]];
    return path;
}

+ (void) saveDictionary {
    NSMutableDictionary *dictionary = [XASVenueOwner dictionary];
    if([NSKeyedArchiver archiveRootObject:dictionary toFile:[XASVenueOwner dictionaryPath]]) {
    } else {
        NSLog(@"Failed to save dictionary");
    }
}

+ (NSMutableArray*)arrayFromJSONArray:(NSArray *)jsonArray {
    NSMutableArray *objectsArray = [NSMutableArray array];
    NSMutableDictionary *dictionary = [XASVenueOwner dictionary];
    
    
    for(NSDictionary *objectDictionary in jsonArray) {
        XASVenueOwner *object = [[XASVenueOwner alloc] initWithDictionary:objectDictionary];
        [dictionary setObject:object forKey:object.remoteID];
        
        [objectsArray addObject:object];
    }
    [XASVenueOwner saveDictionary];
    
    return objectsArray;
}




+ (void)fetchAllInBackgroundWithBlock:(XASArrayResultBlock)block {
    
    NSString *command = @"venue_owners.json";
    
    [self sendRequestToServer:command block:block];
}

+ (void)fetchAllInBackgroundFor:(XASBaseObject*)object withBlock:(XASArrayResultBlock)block {
    NSString *command = [NSString stringWithFormat:@"regions/%@/venue_owners.json", object.remoteID];
    
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
    if([[objectDictionary valueForKey:@"latitude"] isKindOfClass:[NSNull class]] == NO) {
        NSNumber * latNumber = [f numberFromString:[objectDictionary valueForKey:@"latitude"]];
        self.locationLat = latNumber;

    }
    
    if([[objectDictionary valueForKey:@"longitude"] isKindOfClass:[NSNull class]] == NO) {
        NSNumber * longNumber = [f numberFromString:[objectDictionary valueForKey:@"longitude"]];
        self.locationLong = longNumber;

    }
    
}


@end
