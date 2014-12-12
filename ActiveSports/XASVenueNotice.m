//
//  XASVenueNotice.m
//  ActiveSports
//
//  Created by Andrew Sage on 12/12/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASVenueNotice.h"

@implementation XASVenueNotice

+ (NSString *)szClassName {
    return @"VenueNotice";
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
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[XASVenueNotice szClassName], @"123"]];
    return path;
}

+ (void) saveDictionary {
    NSMutableDictionary *dictionary = [XASVenueNotice dictionary];
    if([NSKeyedArchiver archiveRootObject:dictionary toFile:[XASVenueNotice dictionaryPath]]) {
    } else {
        NSLog(@"Failed to save dictionary");
    }
}

+ (NSMutableArray*)arrayFromJSONArray:(NSArray *)jsonArray {
    NSMutableArray *objectsArray = [NSMutableArray array];
    
    for(NSDictionary *objectDictionary in jsonArray) {
        XASVenueNotice *venueNotice = [[XASVenueNotice alloc] init];
        
        [venueNotice updateBasicInformation:objectDictionary];
        
        venueNotice.message = [objectDictionary objectForKey:@"message"];
        
        [objectsArray addObject:venueNotice];
    }
    
    return objectsArray;
}


+ (void)fetchAllInBackgroundWithBlock:(XASArrayResultBlock)block {
    
    NSString *command = @"venue_notices.json";
    
    [self sendRequestToServer:command block:block];
}


- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_message forKey:@"message"];
    [encoder encodeObject:_venue forKey:@"venue"];
    [encoder encodeObject:_starts forKey:@"starts"];
    [encoder encodeObject:_expires forKey:@"expires"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self=[super initWithCoder:decoder])) {
        _message = [decoder decodeObjectForKey:@"message"];
        _venue = [decoder decodeObjectForKey:@"venue"];
        _starts = [decoder decodeObjectForKey:@"starts"];
        _expires = [decoder decodeObjectForKey:@"expires"];

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
    
    self.message = [objectDictionary valueForKey:@"message"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
    self.starts = [dateFormatter dateFromString:[objectDictionary valueForKey:@"starts"]];
    NSString *expiresString = [objectDictionary valueForKey:@"expires"];
    if([expiresString isKindOfClass:[NSNull class]] == NO) {
        if(expiresString) {
            self.expires = [dateFormatter dateFromString:expiresString];
        }
    }

    NSDictionary *venueDictionary = [objectDictionary objectForKey:@"venue"];
    if(venueDictionary) {
        self.venue = [[XASVenue alloc] initWithDictionary:venueDictionary];
        [[XASVenue dictionary] setObject:self.venue forKey:self.venue.remoteID];
        [XASVenue saveDictionary];
    }
}


@end
