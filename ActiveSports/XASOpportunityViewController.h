//
//  XASOpportunityViewController.h
//  ActiveSports
//
//  Created by Andrew Sage on 01/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


#import "XASOpportunity.h"


@interface XASOpportunityViewController : UITableViewController <MKMapViewDelegate>

@property (nonatomic, strong) XASOpportunity *opportunity;


@end
