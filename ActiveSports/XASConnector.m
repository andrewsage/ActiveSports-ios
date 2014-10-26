//
//  XASConnector.m
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASConnector.h"

@interface XASConnector () {
    NSInteger _networkSessions;
}
@end

@implementation XASConnector

+(XASConnector *)sharedInstance {
    static dispatch_once_t once;
    static XASConnector * sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if(self) {
        
        self.serverAPIBaseURL = nil;
        _networkSessions = 0;
        _debugMode = NO;
        
        NSString *deviceCacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        self.cacheDirectory = [deviceCacheDirectory stringByAppendingPathComponent:@"XASConnectorObjects"];
        NSLog(@"cachPath is %@",self.cacheDirectory);
        
        BOOL isDir = NO;
        NSError *error;
        if (! [[NSFileManager defaultManager] fileExistsAtPath:self.cacheDirectory isDirectory:&isDir]) {
            [[NSFileManager defaultManager]createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
            NSLog(@"Error after creating directory:\n%@",error);
        } else {
            // file exists - I don't expect to use the else block. This is for figuring out what's going on.
            // NSLog(@"File %@ exists -- is it a directory? %@",self.cacheDirectory, isDir?@"YES":@"NO");
        }
    }
    
    return self;
}

- (void)startNetworkTraffic {
    
    if(_networkSessions == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    _networkSessions++;
    
    if(self.debugMode) {
        NSLog(@"Network Sessions %ld", (long)_networkSessions);
    }
}

- (void)stopNetworkTraffic {
    
    _networkSessions--;
    
    if(self.debugMode) {
        NSLog(@"Network Sessions %ld", (long)_networkSessions);
    }
    
    if(_networkSessions == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


@end
