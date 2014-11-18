//
//  XASOpportunitiesTableViewController.h
//  ActiveSports
//
//  Created by Andrew Sage on 18/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "XASVenue.h"


typedef enum {
    XASOpportunitiesViewAll,
    XASOpportunitiesViewVenue,
    XASOpportunitiesViewLikes,
    XASOpportunitiesViewFavourites
} XASOpportunitiesView;


@interface XASOpportunitiesTableViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) XASVenue *venue;
@property(nonatomic, assign) XASOpportunitiesView viewType;


@end
