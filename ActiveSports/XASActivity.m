//
//  XASActivity.m
//  ActiveSports
//
//  Created by Andrew Sage on 17/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASActivity.h"

@implementation XASActivity

+ (NSString *)szClassName {
    return @"Activity";
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
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[XASActivity szClassName], @"123"]];
    return path;
}

+ (void) saveDictionary {
    NSMutableDictionary *dictionary = [XASActivity dictionary];
    if([NSKeyedArchiver archiveRootObject:dictionary toFile:[XASActivity dictionaryPath]]) {
    } else {
        NSLog(@"Failed to save dictionary");
    }
}

+ (NSMutableArray*)arrayFromJSONArray:(NSArray *)jsonArray {
    
    NSMutableArray *objectsArray = [NSMutableArray array];
    NSMutableDictionary *dictionary = [XASActivity dictionary];
    
    
    for(NSDictionary *objectDictionary in jsonArray) {
        XASActivity *object = [[XASActivity alloc] initWithDictionary:objectDictionary];
        [dictionary setObject:object forKey:object.remoteID];
        
        [objectsArray addObject:object];
    }
    [XASActivity saveDictionary];
    
    return objectsArray;
}


+ (void)fetchAllInBackgroundWithBlock:(XASArrayResultBlock)block {
    
    NSString *command = @"activities.json";
    
    [self sendRequestToServer:command block:block];
}


- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self=[super initWithCoder:decoder])) {
        _title = [decoder decodeObjectForKey:@"title"];
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
    
    self.title = [objectDictionary valueForKey:@"title"];
}


@end
