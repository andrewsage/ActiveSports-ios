//
//  XASVenueTableViewController.h
//  ActiveSports
//
//  Created by Andrew Sage on 14/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XASVenue.h"
#import <MapKit/MapKit.h>


@interface XASVenueTableViewController : UITableViewController <MKMapViewDelegate>

@property (nonatomic, strong) XASVenue *venue;


@end
