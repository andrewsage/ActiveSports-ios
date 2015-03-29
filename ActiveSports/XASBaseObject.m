//
//  XASBaseObject.m
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASBaseObject.h"

@implementation XASBaseObject

+ (NSMutableArray*)arrayFromJSONArray:(NSArray *)jsonArray {
    NSMutableArray *objectsArray = [NSMutableArray array];
    
    
    return objectsArray;
}

+ (void)fetchAllInBackgroundWithBlock:(XASArrayResultBlock)block {
    
    NSError *error;
    
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:@"fetchAllInBackgroundWithBlock method not implemented for getting this kind of object" forKey:NSLocalizedDescriptionKey];
    error = [NSError errorWithDomain:@"XASObjects" code:200 userInfo:details];
    block(nil, error);
}

+ (void)fetchAllInBackgroundFor:(XASBaseObject*)object withBlock:(XASArrayResultBlock)block {
    
    NSError *error;
    
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:@"fetchAllInBackgroundWithBlock method not implemented for getting this kind of object" forKey:NSLocalizedDescriptionKey];
    error = [NSError errorWithDomain:@"XASObjects" code:200 userInfo:details];
    block(nil, error);
}

+ (NSString *)szClassName {
    return @"BaseObject";
}

+ (NSString*)cacheDirectory {
    
    static NSString *cacheDirectoryPath = nil;
    
    NSString *deviceCacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    cacheDirectoryPath = [deviceCacheDirectory stringByAppendingPathComponent:@"XASObjects"];
    //NSLog(@"cachPath is %@", cacheDirectoryPath);
    
    BOOL isDir = NO;
    NSError *error;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cacheDirectoryPath isDirectory:&isDir]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:cacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"Error after creating directory:\n%@",error);
    } else {
        // file exists - I don't expect to use the else block. This is for figuring out what's going on.
        //NSLog(@"File %@ exists -- is it a directory? %@",cacheDirectoryPath, isDir?@"YES":@"NO");
    }
    
    return cacheDirectoryPath;
}


- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_remoteID forKey:@"RemoteID"];
    [encoder encodeObject:_createdAt forKey:@"CreatedAt"];
    [encoder encodeObject:_updatedAt forKey:@"UpdatedAt"];
    //[encoder encodeObject:[NSNumber numberWithBool:_onServer] forKey:@"onServer"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self=[self init])) {
        _remoteID = [decoder decodeObjectForKey:@"RemoteID"];
        _createdAt = [decoder decodeObjectForKey:@"CreatedAt"];
        _updatedAt = [decoder decodeObjectForKey:@"UpdatedAt"];
        
        NSNumber *boolNumber = [decoder decodeObjectForKey:@"onServer"];
        //self.onServer = boolNumber.boolValue;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)objectDictionary {
    self = [super init];
    
    if(self) {
        [self updateInformation:objectDictionary];
    }
    
    return self;
}

- (void)fetchIfNeededInBackgroundWithBlock:(XASBaseObjectResultBlock)block {
    
    NSError *error;
    
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:@"fetchIfNeededInBackgroundWithBlock method not implemented for getting this kind of object" forKey:NSLocalizedDescriptionKey];
    error = [NSError errorWithDomain:@"XAZ" code:200 userInfo:details];
    block(nil, error);
}

- (void)sendSingleRequestToServer:(NSString *)command block:(XASBaseObjectResultBlock)block {
    XASConnector *connector = [XASConnector sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",
                           connector.serverAPIBaseURL,
                           command];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:kTimeoutInterval];
    
    
    request.timeoutInterval = 240;
    
    [connector startNetworkTraffic];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [connector stopNetworkTraffic];
                               
                               if(error) {
                                   NSLog(@"Connection failed: %@", error.localizedDescription);
                                   NSLog(@"We sent to: %@", response.URL);
                                   block(nil, error);
                               } else {
                                   NSLog(@"We sent to: %@", response.URL);
                                   
                                   NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                   NSInteger responseStatusCode = [httpResponse statusCode];
                                   
                                   NSLog(@"Response status code: %ld", (long)responseStatusCode);
                                   NSLog(@"%@", [NSHTTPURLResponse localizedStringForStatusCode:responseStatusCode]);
                                   switch (responseStatusCode) {
                                       case 200: {
                                           NSString* dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                           
                                           if(connector.debugMode) {
                                               NSLog(@"Data received: %@", dataAsString);
                                           }
                                           
                                           if(connector.debugMode) {
                                               NSLog(@"Responding to a %@ request", request.HTTPMethod);
                                           }
                                           
                                           NSError *jsonError;
                                           NSDictionary *jsonDictionary = nil;
                                           
                                           jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                           
                                           if(connector.debugMode) {
                                               NSLog(@"dictionary of data: %@", jsonDictionary);
                                           }
                                           
                                           [self updateInformation:jsonDictionary];
                                           
                                           block(self, error);
                                       }
                                           break;
                                           
                                       case 500:
                                           NSLog(@"Internal Server error: response 500");
                                           break;
                                           
                                       default:
                                           NSLog(@"Connection did receive response: %@", response);
                                           
                                           break;
                                   }
                               }
                           }];

}

+ (void)sendRequestToServer:(NSString *)command block:(XASArrayResultBlock)block {
    XASConnector *connector = [XASConnector sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",
                           connector.serverAPIBaseURL,
                           command];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:kTimeoutInterval];
    
    
    request.timeoutInterval = 240;
    
    [connector startNetworkTraffic];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [connector stopNetworkTraffic];
                               
                               if(error) {
                                   NSLog(@"Connection failed: %@", error.localizedDescription);
                                   NSLog(@"We sent to: %@", response.URL);
                                   block(nil, error);
                               } else {
                                   NSLog(@"We sent to: %@", response.URL);
                                   
                                   NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                   NSInteger responseStatusCode = [httpResponse statusCode];
                                   
                                   NSLog(@"Response status code: %ld", (long)responseStatusCode);
                                   NSLog(@"%@", [NSHTTPURLResponse localizedStringForStatusCode:responseStatusCode]);
                                   switch (responseStatusCode) {
                                       case 200: {
                                           NSString* dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                           
                                           if(connector.debugMode) {
                                               NSLog(@"Data received: %@", dataAsString);
                                           }
                                           
                                           if(connector.debugMode) {
                                               NSLog(@"Responding to a %@ request", request.HTTPMethod);
                                           }
                                           
                                           NSError *jsonError;
                                           NSArray *jsonArray = nil;
                                           
                                           jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                           
                                           if(connector.debugMode) {
                                               NSLog(@"array of data: %@", jsonArray);
                                           }
                                           
                                           NSMutableArray *objectsArray = [self arrayFromJSONArray:jsonArray];
                                           
                                           block(objectsArray, error);
                                       }
                                           break;
                                           
                                       case 500:
                                           NSLog(@"Internal Server error: response 500");
                                           break;
                                           
                                       default:
                                           NSLog(@"Connection did receive response: %@", response);
                                           
                                           break;
                                   }
                               }
                           }];
}

- (void)updateBasicInformation:(NSDictionary *)objectDictionary {
    self.remoteID = [objectDictionary valueForKey:@"id"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    self.createdAt = [dateFormatter dateFromString:[objectDictionary valueForKey:@"created_at"]];
    self.updatedAt = [dateFormatter dateFromString:[objectDictionary valueForKey:@"updated_at"]];
}

- (void)updateInformation:(NSDictionary *)objectDictionary {
    
    [self updateBasicInformation:objectDictionary];
}

@end
