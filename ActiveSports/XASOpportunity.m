//
//  XASOpportunity.m
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASOpportunity.h"

@implementation XASOpportunity

+ (NSString *)szClassName {
    return @"Opportunity";
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
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[XASOpportunity szClassName], @"123"]];
    return path;
}

+ (void) saveDictionary {
    NSMutableDictionary *dictionary = [XASOpportunity dictionary];
    if([NSKeyedArchiver archiveRootObject:dictionary toFile:[XASOpportunity dictionaryPath]]) {
    } else {
        NSLog(@"Failed to save dictionary");
    }
}

+ (NSMutableArray*)arrayFromJSONArray:(NSArray *)jsonArray {
    NSMutableArray *objectsArray = [NSMutableArray array];
    NSMutableDictionary *dictionary = [XASOpportunity dictionary];

    
    for(NSDictionary *objectDictionary in jsonArray) {
        XASOpportunity *object = [[XASOpportunity alloc] initWithDictionary:objectDictionary];
        [dictionary setObject:object forKey:object.remoteID];

        [objectsArray addObject:object];
    }
    [XASOpportunity saveDictionary];

    
    return objectsArray;
}


+ (void)fetchAllInBackgroundWithBlock:(XASArrayResultBlock)block {
    
    NSString *command = @"opportunities.json";
    
    [self sendRequestToServer:command block:block];
}


+ (void)fetchAllInBackgroundFor:(XASBaseObject*)object withBlock:(XASArrayResultBlock)block {
    NSString *command = [NSString stringWithFormat:@"regions/%@/opportunities.json", object.remoteID];
    
    [self sendRequestToServer:command block:block];
}

- (id)initWithDictionary:(NSDictionary*)objectDictionary {
    self = [super initWithDictionary:objectDictionary];
    
    if(self) {
        [self updateInformation:objectDictionary];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_startTime forKey:@"startTime"];
    [encoder encodeObject:_endTime forKey:@"endTime"];
    [encoder encodeObject:_dayOfWeek forKey:@"dayOfWeek"];
    [encoder encodeObject:_venue forKey:@"venue"];
    [encoder encodeObject:_opportunityDescription forKey:@"description"];
    [encoder encodeObject:_effortRating forKey:@"effortRating"];
    [encoder encodeObject:_imageURL forKey:@"imageURL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self=[super initWithCoder:decoder])) {
        _name = [decoder decodeObjectForKey:@"name"];
        _startTime = [decoder decodeObjectForKey:@"startTime"];
        _endTime = [decoder decodeObjectForKey:@"endTime"];
        _dayOfWeek = [decoder decodeObjectForKey:@"dayOfWeek"];
        _venue = [decoder decodeObjectForKey:@"venue"];
        _opportunityDescription = [decoder decodeObjectForKey:@"description"];
        _effortRating = [decoder decodeObjectForKey:@"effortRating"];
        _imageURL = [decoder decodeObjectForKey:@"imageURL"];
    }
    return self;
}


- (void)updateInformation:(NSDictionary *)objectDictionary {
    [super updateInformation:objectDictionary];
    
    self.name = [objectDictionary valueForKey:@"name"];
    self.startTime = [objectDictionary valueForKey:@"start_time"];
    self.endTime = [objectDictionary valueForKey:@"end_time"];
    self.dayOfWeek = [objectDictionary valueForKey:@"day_of_week"];
    self.opportunityDescription = [objectDictionary valueForKey:@"description"];
    self.imageURL = [objectDictionary valueForKey:@"image_url"];
    
    self.effortRating = [objectDictionary valueForKey:@"effort_rating"];
    
    NSDictionary *venueDictionary = [objectDictionary objectForKey:@"venue"];
    if(venueDictionary) {
        self.venue = [[XASVenue alloc] initWithDictionary:venueDictionary];
        [[XASVenue dictionary] setObject:self.venue forKey:self.venue.remoteID];
        [XASVenue saveDictionary];
    }
    
}

- (void)rateInBackground:(NSInteger)rating withBlock:(XASBooleanResultBlock)block {
    
    XASConnector *connector = [XASConnector sharedInstance];
    
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    [dataDictionary setObject:[NSNumber numberWithInteger:rating] forKey:@"effort_rating[rating]"];
    
    NSMutableString *requestString = [NSMutableString stringWithString:@""];
    for(NSString *key in dataDictionary) {
        [requestString appendFormat:@"%@=%@&", key, [dataDictionary objectForKey:key]];
    }
    
    NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length:[requestString length]];
    
    // POST /opportunities/:id/effort_ratings
    NSString *postUrlString = [NSString stringWithFormat:@"%@/opportunities/%@/effort_ratings.json",
                               connector.serverAPIBaseURL,
                               self.remoteID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:kTimeoutInterval];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    
    request.timeoutInterval = 240;
    
    [connector startNetworkTraffic];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [connector stopNetworkTraffic];
                               
                               NSLog(@"We sent %@ to: %@",
                                     request.HTTPMethod,
                                     response.URL);
                               
                               if(error) {
                                   NSLog(@"Connection failed: %@", error.localizedDescription);
                                   block(NO, error);
                               } else {
                                   
                                   NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                   NSInteger responseStatusCode = [httpResponse statusCode];
                                   
                                   NSLog(@"Response status code: %ld", (long)responseStatusCode);
                                   NSLog(@"%@", [NSHTTPURLResponse localizedStringForStatusCode:responseStatusCode]);
                                   switch (responseStatusCode) {
                                           
                                       case 201: {
                                           NSString* dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                           
                                           NSLog(@"Data received: %@", dataAsString);
                                           
                                           NSError *jsonError;
                                           NSDictionary *jsonDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                           NSDictionary *opportunityDictionary = [jsonDictionary objectForKey:@"opportunity"];
                                           [self updateInformation:opportunityDictionary];
                                           [[XASOpportunity dictionary] setObject:self forKey:self.remoteID];
                                           [XASOpportunity saveDictionary];
                                           
                                           block(YES, nil);
                                           
                                       }
                                           break;
                                           
                                       case 400: {
                                           NSError *error;
                                           
                                           NSString* dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                           
                                           NSLog(@"Data received: %@", dataAsString);
                                           
                                           NSMutableDictionary* details = [NSMutableDictionary dictionary];
                                           [details setValue:[NSString stringWithFormat:@"Bad request - %@", dataAsString]forKey:NSLocalizedDescriptionKey];
                                           error = [NSError errorWithDomain:@"SZAPI" code:400 userInfo:details];
                                           
                                           block(NO, error);
                                       }
                                           break;
                                           
                                       case 404: {
                                           NSError *error;
                                           
                                           NSString* dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                           
                                           NSLog(@"Data received: %@", dataAsString);
                                           
                                           NSMutableDictionary* details = [NSMutableDictionary dictionary];
                                           [details setValue:[NSString stringWithFormat:@"Not found - %@", dataAsString]forKey:NSLocalizedDescriptionKey];
                                           error = [NSError errorWithDomain:@"SZAPI" code:404 userInfo:details];
                                           
                                           block(NO, error);
                                       }
                                           break;
                                           
                                           
                                       case 500: {
                                           NSError *error;
                                           
                                           NSMutableDictionary* details = [NSMutableDictionary dictionary];
                                           [details setValue:@"Internal Server error: response 500"
                                                      forKey:NSLocalizedDescriptionKey];
                                           error = [NSError errorWithDomain:@"SZAPI" code:500 userInfo:details];
                                           
                                           block(NO, error);
                                       }
                                           
                                           break;
                                           
                                       default:
                                           NSLog(@"Connection did receive response: %@", response);
                                           
                                           block(NO, nil);
                                           
                                           break;
                                   }
                               }
                           }];
}



@end
