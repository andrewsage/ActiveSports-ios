//
//  XASOpportunityDetailsViewController.h
//  ActiveSports
//
//  Created by Andrew Sage on 19/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


#import "XASOpportunity.h"

@interface XASOpportunityDetailsViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) XASOpportunity *opportunity;

@end
