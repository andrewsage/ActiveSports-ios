//
//  VenueAnnotation.h
//  ActiveSports
//
//  Created by Andrew Sage on 03/12/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
#import "XASVenue.h"

@interface XASVenueAnnotation : NSObject <MKAnnotation> 
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *numberOfActivities;
@property(nonatomic, retain) XASVenue *venue;

@end
