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
    [encoder encodeObject:_activity forKey:@"activity"];
    [encoder encodeObject:_tagsArray forKey:@"tags"];
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
        _activity = [decoder decodeObjectForKey:@"activity"];
        _tagsArray = [decoder decodeObjectForKey:@"tags"];
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
    if([self.imageURL isKindOfClass:[NSNull class]] == NO) {
        self.imageURL = [self.imageURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    NSDictionary *activityDictionary = [objectDictionary valueForKey:@"activity"];
    if(activityDictionary) {
        self.activity = [[XASActivity alloc] initWithDictionary:activityDictionary];
        [[XASActivity dictionary] setObject:self.activity forKey:self.activity.remoteID];
        [XASActivity saveDictionary];
    }
    
    self.effortRating = [objectDictionary valueForKey:@"effort_rating"];
    
    NSDictionary *venueDictionary = [objectDictionary objectForKey:@"venue"];
    if(venueDictionary) {
        self.venue = [[XASVenue alloc] initWithDictionary:venueDictionary];
        [[XASVenue dictionary] setObject:self.venue forKey:self.venue.remoteID];
        [XASVenue saveDictionary];
    }
    
    NSArray *tagListArray = [objectDictionary objectForKey:@"tag_list"];
    if(tagListArray) {
        self.tagsArray = [NSMutableArray arrayWithArray:tagListArray];
        
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

+ (NSArray*)forVenue:(XASVenue*)venue {
    NSMutableArray *opportunitiesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSDictionary *dictionary = [XASOpportunity dictionary];
    for(NSString *key in dictionary.allKeys) {
        XASOpportunity *opportunity = [dictionary objectForKey:key];
        if([opportunity.venue.remoteID isEqual:venue.remoteID]) {
            
            [opportunitiesArray addObject:opportunity];
        }
    }
    
    return opportunitiesArray;
}

+ (NSArray*)forFavourites {
    
    NSDictionary *favouritesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self favouritesFilepath]];
    
    if(favouritesDictionary == nil) {
        favouritesDictionary = [NSDictionary dictionary];
    }
    
    NSMutableArray *opportunitiesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSDictionary *dictionary = [XASOpportunity dictionary];
    for(NSString *key in dictionary.allKeys) {
        XASOpportunity *opportunity = [dictionary objectForKey:key];
        
        NSNumber *included = [favouritesDictionary objectForKey:opportunity.remoteID];
        
        if(included.boolValue) {
            [opportunitiesArray addObject:opportunity];
        }
    }
    
    return opportunitiesArray;
}

+ (NSArray*)forSearch:(NSDictionary *)searchDictionary {
    
    NSMutableArray *opportunitiesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSDictionary *dictionary = [XASOpportunity dictionary];
    for(NSString *key in dictionary.allKeys) {
        BOOL include = YES;
        
        XASOpportunity *opportunity = [dictionary objectForKey:key];
        NSArray *startTimeComponents = [opportunity.startTime componentsSeparatedByString:@":"];
        NSInteger startHour = [[startTimeComponents objectAtIndex:0] integerValue];
        
        NSArray *dayNameArray = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @""];
        NSNumber *dayOfWeekNumber = [searchDictionary objectForKey:@"dayOfWeek"];
        NSString *dayName = [dayNameArray objectAtIndex:dayOfWeekNumber.integerValue];
        NSNumber *timeOfDayNumber = [searchDictionary objectForKey:@"timeOfDay"];
        
        NSNumber *minimumExertion = [searchDictionary objectForKey:@"minimumExertion"];
        NSNumber *maximumExertion = [searchDictionary objectForKey:@"maximumExertion"];
        
        NSString *venueID = [searchDictionary objectForKey:@"venue"];
        NSString *textSearch = [searchDictionary objectForKey:@"text"];
        
        if(textSearch) {
            if([textSearch isEqualToString:@""] == NO) {
                
                if([opportunity.name rangeOfString:textSearch options:NSCaseInsensitiveSearch].location == NSNotFound) {
                    if([opportunity.description rangeOfString:textSearch options:NSCaseInsensitiveSearch].location == NSNotFound) {
                        include = NO;
                    }
                }
            }
        }
        
        if([searchDictionary objectForKey:@"venue"]) {
            if([venueID isEqual:opportunity.venue.remoteID] == NO) {
                include = NO;
            }
        }
        
        if([searchDictionary objectForKey:@"tag"]) {
            BOOL matches = NO;
            for(NSString *tag in [searchDictionary objectForKey:@"tag"]) {
                if([opportunity.tagsArray containsObject:tag]) {
                    matches = YES;
                }
            }
            if(matches == NO) {
                include = NO;
            }
        }
        
        if(minimumExertion.integerValue > 1 || maximumExertion.integerValue < 5) {
            if(opportunity.effortRating < minimumExertion && [searchDictionary objectForKey:@"minimumExertion"]) {
                include = NO;
            }
            
            if(opportunity.effortRating > maximumExertion && [searchDictionary objectForKey:@"maximumExertion"]) {
                include = NO;
            }
        }
        
        if([searchDictionary objectForKey:@"timeOfDay"]) {
            switch (timeOfDayNumber.integerValue) {
                case 0: // Morning 00:00 - 11:59
                    if(startHour >= 12) {
                        include = NO;
                    }
                    break;
                    
                case 1: // Afternoon 12:00 - 16:59
                    if(startHour < 12 || startHour >= 17) {
                        include = NO;
                    }
                    break;
                    
                case 2: // Evening 17:00 - 23:59
                    if(startHour < 17) {
                        include = NO;
                    }
                    break;
                    
                default:
                    break;
            }
        }
        
        if([dayName isEqualToString:@""] == NO) {
            if([opportunity.dayOfWeek isEqualToString:dayName] == NO && [searchDictionary objectForKey:@"dayOfWeek"]) {
                include = NO;
            }
        }
        
        if(include) {
            [opportunitiesArray addObject:opportunity];
        }
    }
    
    return opportunitiesArray;
}

+ (NSArray*)forTodayWithSearch:(NSDictionary *)searchDictionary {
    
    NSDictionary *preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(preferencesDictionary == nil) {
        preferencesDictionary = [NSDictionary dictionary];
    }
    
    NSMutableArray *opportunitiesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSDictionary *dictionary = [XASOpportunity dictionary];
    for(NSString *key in dictionary.allKeys) {
        BOOL include = YES;
        
        XASOpportunity *opportunity = [dictionary objectForKey:key];
        NSArray *dayNameArray = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @""];
        NSNumber *dayOfWeekNumber = [searchDictionary objectForKey:@"dayOfWeek"];
        NSString *dayName = [dayNameArray objectAtIndex:dayOfWeekNumber.integerValue];
        
        
        NSString *venueID = [searchDictionary objectForKey:@"venue"];
        
        if([searchDictionary objectForKey:@"venue"]) {
            if([venueID isEqual:opportunity.venue.remoteID] == NO) {
                include = NO;
            }
        }
        
        if([searchDictionary objectForKey:@"tag"]) {
            BOOL matches = NO;
            for(NSString *tag in [searchDictionary objectForKey:@"tag"]) {
                if([opportunity.tagsArray containsObject:tag]) {
                    matches = YES;
                }
            }
            if(matches == NO) {
                include = NO;
            }
        }
    
        NSNumber *likes = [preferencesDictionary objectForKey:opportunity.activity.remoteID];
        if(likes) {
            if(likes.boolValue == NO) {
                include = NO;
            }
        } else {
            include = NO;
        }
        
        if([dayName isEqualToString:@""] == NO) {
            if([opportunity.dayOfWeek isEqualToString:dayName] == NO && [searchDictionary objectForKey:@"dayOfWeek"]) {
                include = NO;
            }
        }
        
        if(include) {
            [opportunitiesArray addObject:opportunity];
        }
    }
    
    return opportunitiesArray;
}

#pragma mark - Preferences
+ (NSString*)preferencesFilepath {
    
    
    NSString *documentsDir = [XASBaseObject cacheDirectory];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"profile"]];
    
    return path;
}

+ (NSString*)favouritesFilepath {
    
    NSString *documentsDir = [XASBaseObject cacheDirectory];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"favourites"]];
    
    return path;
}


@end
