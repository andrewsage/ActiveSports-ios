//
//  XASBaseObject.h
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XASConnector.h"


@interface XASBaseObject : NSObject <NSCoding>

@property (nonatomic, copy) NSString *remoteID;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSDate *updatedAt;


+ (NSString *)szClassName;
+ (NSString*)cacheDirectory;
- (NSString*)objectId;

- (id)initWithDictionary:(NSDictionary*)objectDictionary;



+ (void)fetchAllInBackgroundWithBlock:(XASArrayResultBlock)block;
+ (void)fetchAllInBackgroundFor:(XASBaseObject*)object withBlock:(XASArrayResultBlock)block;
- (void)fetchIfNeededInBackgroundWithBlock:(XASBaseObjectResultBlock)block;


+ (NSMutableArray*)arrayFromJSONArray:(NSArray *)jsonArray;
+ (void)sendRequestToServer:(NSString *)command block:(XASArrayResultBlock)block;
- (void)sendSingleRequestToServer:(NSString *)command block:(XASBaseObjectResultBlock)block;

- (void)updateBasicInformation:(NSDictionary*)objectDictionary;
- (void)updateInformation:(NSDictionary*)objectDictionary;

@end
