//
//  XASConnector.h
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class XASBaseObject;

static const int kTimeoutInterval = 20; // 20 seconds
typedef void (^XASArrayResultBlock)(NSArray *array, NSError *error);
typedef void (^XASBaseObjectResultBlock)(XASBaseObject *object, NSError *error);
typedef void (^XASBooleanResultBlock)(BOOL succeeded, NSError *error);



@interface XASConnector : NSObject

@property (strong, nonatomic) NSString *applicationAPIKey;
@property (strong, nonatomic) NSString *serverAPIBaseURL;
@property (strong, nonatomic) NSString *authenticationToken;
@property (nonatomic, assign) BOOL debugMode;
@property (strong, nonatomic) NSString *cacheDirectory;

+ (XASConnector*)sharedInstance;

- (void)startNetworkTraffic;
- (void)stopNetworkTraffic;


@end
