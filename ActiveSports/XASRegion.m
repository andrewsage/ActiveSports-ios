//
//  XASRegion.m
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASRegion.h"

@implementation XASRegion

+ (NSMutableArray*)arrayFromJSONArray:(NSArray *)jsonArray {
    NSMutableArray *objectsArray = [NSMutableArray array];
    
    for(NSDictionary *objectDictionary in jsonArray) {
        XASRegion *region = [[XASRegion alloc] init];
        
        [region updateBasicInformation:objectDictionary];
        
        region.name = [objectDictionary objectForKey:@"name"];
        
        [objectsArray addObject:region];
    }
    
    return objectsArray;
}

+ (void)fetchAllInBackgroundWithBlock:(XASArrayResultBlock)block {
    
    NSString *command = @"regions.json";
    
    [self sendRequestToServer:command block:block];
}

- (void)fetchIfNeededInBackgroundWithBlock:(XASBaseObjectResultBlock)block {
    
    NSString *command = [NSString stringWithFormat:@"regions/%@.json", self.remoteID];

    [self sendSingleRequestToServer:command block:block];
}

- (void)updateInformation:(NSDictionary *)objectDictionary {
    [super updateInformation:objectDictionary];
    
    NSLog(@"updating a Region");
}
@end
