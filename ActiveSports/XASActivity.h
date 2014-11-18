//
//  XASActivity.h
//  ActiveSports
//
//  Created by Andrew Sage on 17/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASBaseObject.h"

@interface XASActivity : XASBaseObject

@property (nonatomic, copy) NSString *title;


+ (NSMutableDictionary *) dictionary;
+ (NSString *)dictionaryPath;
+ (void)saveDictionary;

@end
