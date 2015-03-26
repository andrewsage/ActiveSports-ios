//
//  XASTodayHomeViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 01/12/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASTodayHomeViewController.h"
#import "XASOpportunitiesTableViewController.h"
#import "XASVenueAnnotation.h"
#import "XASOpportunity.h"
#import "UIImage+Resize.h"
#import "UIColor+Expanded.h"
#import "Constants.h"

@interface XASTodayHomeViewController () {
    
    NSMutableArray *_tagsArray;
    NSMutableDictionary *_collectionsDictionary;
    NSString *_timeOfDay;
}

@property (weak, nonatomic) IBOutlet UIButton *strengthButton;
@property (weak, nonatomic) IBOutlet UIButton *cardioButton;
@property (weak, nonatomic) IBOutlet UIButton *weightLossButton;
@property (weak, nonatomic) IBOutlet UIButton *flexibilityButton;
@property (weak, nonatomic) IBOutlet UIButton *resultsButton;
@property (weak, nonatomic) IBOutlet UILabel *greetingLabel;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end

@implementation XASTodayHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _tagsArray = [NSMutableArray arrayWithCapacity:0];
    
    NSArray *buttonsArray = @[self.strengthButton, self.cardioButton, self.weightLossButton, self.flexibilityButton];
    for(UIButton *button in buttonsArray) {
        button.layer.borderWidth = 1.0f;
        button.layer.cornerRadius = 5.0f;
        button.layer.borderColor = [UIColor colorWithHexString:XASBrandMainColor].CGColor;

        [self buttonPressed:button];
    }
    
    self.resultsButton.layer.cornerRadius = 2.0f;
    
    [self.resultsButton setBackgroundColor:[UIColor colorWithHexString:XASPositveActionColor]];
    [self.resultsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.title = @"What's on today?";
    
    NSDate *now = [NSDate date];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
    NSInteger hour = [components hour];
    
    // Morning 00:00 - 11:59
    // Afternoon 12:00 - 16:59
    // Evening 17:00 - 23:59
    if(hour >= 17) {
        _timeOfDay = @"evening";
    } else if (hour >= 12) {
        _timeOfDay = @"afternoon";
    } else {
        _timeOfDay = @"morning";
    }
    
    
    self.greetingLabel.text = [NSString stringWithFormat:@"Good %@!", _timeOfDay];
    
    self.mapView.delegate = self;
    
    
    [self rebuildContent];
}


- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:XASBrandMainColor];


    /*
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.090 green:0.161 blue:0.490 alpha:1], NSForegroundColorAttributeName, nil];
    */
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"results"]) {
        XASOpportunitiesTableViewController *controller = (XASOpportunitiesTableViewController*)[segue destinationViewController];
        
        NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];
        
        [searchDictionary setObject:_tagsArray forKey:@"tag"];
        
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *weekdayComponents =
        [gregorian components:NSCalendarUnitWeekday fromDate:today];
        NSInteger weekday = [weekdayComponents weekday] - 1;
        
        [searchDictionary setObject:[NSNumber numberWithInteger:weekday] forKey:@"dayOfWeek"];
        
        if([sender isKindOfClass:[XASVenueAnnotation class]]) {
            XASVenueAnnotation *venueAnnotation = (XASVenueAnnotation*)sender;
            [searchDictionary setObject:venueAnnotation.venue.remoteID forKey:@"venue"];
        }
        
        controller.viewType = XASOpportunitiesViewSearch;
        controller.searchDictionary = [NSDictionary dictionaryWithDictionary:searchDictionary];
    }
}

#pragma mark - Actions

- (IBAction)homePressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)buttonPressed:(UIButton *)sender {
    
    NSString *tag = @"";
    if(sender == self.strengthButton) {
        tag = @"strength";
    }
    if(sender == self.cardioButton) {
        tag = @"cardio";
    }
    if(sender == self.weightLossButton) {
        tag = @"weight loss";
    }
    if(sender == self.flexibilityButton) {
        tag = @"flexibility";
    }
    
    if([sender isSelected]) {
        
        [sender setBackgroundColor:[UIColor whiteColor]];
        [sender setTintColor:[UIColor colorWithHexString:XASBrandMainColor]];
        [sender setSelected:NO];
        [_tagsArray removeObject:tag];
    } else {
        [sender setBackgroundColor:[UIColor colorWithHexString:XASBrandMainColor]];
        [sender setTintColor:[UIColor whiteColor]];
        [sender setSelected:YES];
        [_tagsArray addObject:tag];
    }
    
    [self rebuildContent];
}

#pragma mark - Map stuff

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    //[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[XASVenueAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            //pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            //UIImage *scaledImage = [UIImage imageWithImage:[UIImage imageNamed:@"map-pin"] scaledToSize:CGSizeMake(40.0, 54.0)];
            //pinView.image = scaledImage;
            
            pinView.image = [UIImage imageNamed:@"map-pin"];
            
            //pinView.calloutOffset = CGPointMake(0, 32);
            //pinView.pinColor = MKPinAnnotationColorGreen;
            
            // Add an image to the left callout.
            //UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location"]];
            //pinView.leftCalloutAccessoryView = iconView;
        } else {
            pinView.annotation = annotation;
        }
        
        for(UIView *subView in pinView.subviews) {
            [subView removeFromSuperview];
        }
        
        XASVenueAnnotation *venueAnnotation = (XASVenueAnnotation*)annotation;
        UILabel *numberView = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, pinView.frame.size.width, 30)];
        numberView.text = venueAnnotation.numberOfActivities;
        numberView.textAlignment = NSTextAlignmentCenter;
        numberView.font = [UIFont fontWithName:XASFontRegular size:12];
        numberView.textColor = [UIColor colorWithHexString:XASMainTextColor];
        [pinView addSubview:numberView];
        
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

        
        return pinView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    XASVenueAnnotation *venueAnnotation = (XASVenueAnnotation*)view.annotation;
    
    NSLog(@"you touched the disclosure indicator");
    NSLog(@"%@",view.annotation.title);
    NSLog(@"%@", venueAnnotation.venue.name);

    [self performSegueWithIdentifier:@"results" sender:venueAnnotation];
}

- (void)zoomToVenues {
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees minLon = 180.0;
    CLLocationDegrees maxLon = -180.0;
    
    if(self.mapView.annotations.count == 0) {
        return;
    }
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        
        if(annotation != self.mapView.userLocation) {
            if (annotation.coordinate.latitude < minLat) {
                minLat = annotation.coordinate.latitude;
            }
            if (annotation.coordinate.longitude < minLon) {
                minLon = annotation.coordinate.longitude;
            }
            if (annotation.coordinate.latitude > maxLat) {
                maxLat = annotation.coordinate.latitude;
            }
            if (annotation.coordinate.longitude > maxLon) {
                maxLon = annotation.coordinate.longitude;
            }
        }
    }
    
    MKCoordinateSpan span = MKCoordinateSpanMake((maxLat - minLat), (maxLon - minLon));
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat - span.latitudeDelta / 2), maxLon - span.longitudeDelta / 2);
    
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake(center, span)] animated:YES];
    
}


#pragma mark -

- (NSString *)daySuffixForDate:(NSDate *)date {
    
    if ([[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0] isEqualToString:@"en"]) {
        NSInteger day_of_month = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date] day];
        switch (day_of_month) {
            case 1:
            case 21:
            case 31: return @"st";
            case 2:
            case 22: return @"nd";
            case 3:
            case 23: return @"rd";
            default: return @"th";
        }
    } else {
        return @"";
    }
}

- (void)rebuildContent {
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEEE"];
    NSString *todayName = [weekday stringFromDate:now];

    _collectionsDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSDictionary *dictionary = [XASOpportunity dictionary];
    for(NSString *key in dictionary.allKeys) {
        XASOpportunity *opportunity = [dictionary objectForKey:key];
        
        if([opportunity.dayOfWeek isEqualToString:todayName]) {
            
            BOOL include = YES;
            
            
            
            BOOL matches = NO;
            for(NSString *tag in _tagsArray) {
                if([opportunity.tagsArray containsObject:tag]) {
                    matches = YES;
                }
            }
            if(matches == NO) {
                include = NO;
            }
            
            if(include) {
                NSMutableArray *objectsArray = [_collectionsDictionary objectForKey:opportunity.venue.name];
                
                if(objectsArray == nil) {
                    objectsArray = [NSMutableArray array];
                }
                
                [objectsArray addObject:opportunity];
                
                [_collectionsDictionary setObject:objectsArray forKey:opportunity.venue.name];
            }
        }
    }
    
    NSDictionary *venues = [XASVenue dictionary];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSInteger numberOfActivities = 0;
    
    for(NSString *key in venues.allKeys) {
        
        XASVenue *venue = [venues objectForKey:key];
        NSMutableArray *objectsArray = [_collectionsDictionary objectForKey:venue.name];

        if(objectsArray.count > 0) {
            CLLocationCoordinate2D venueCoord = CLLocationCoordinate2DMake(venue.locationLat.doubleValue, venue.locationLong.doubleValue);
            
            XASVenueAnnotation *annotation = [[XASVenueAnnotation alloc] init];
            annotation.title = venue.name;
            
            numberOfActivities += objectsArray.count;
            
            annotation.numberOfActivities = [NSString stringWithFormat:@"%lu", (unsigned long)objectsArray.count];
            annotation.coordinate = venueCoord;
            annotation.venue = venue;
            
            [self.mapView addAnnotation:annotation];
        }
    }
    
    [self zoomToVenues];
    
    //[self.mapView showAnnotations:self.mapView.annotations animated:YES];
    
    [weekday setDateFormat: @"eee dd"];
    todayName = [weekday stringFromDate:now];
    
    NSMutableAttributedString *headerText = [[NSMutableAttributedString alloc] initWithString:@"Activities near you\n"];
    NSMutableAttributedString *bottomText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld Activities - This %@ (%@%@)", (long)numberOfActivities, _timeOfDay, todayName, [self daySuffixForDate:now]]];
    
    UIFont *topRowFont = [UIFont fontWithName:XASFontRegular size:11];
    UIFont *bottomRowFont = [UIFont fontWithName:XASFontBold size:11];
    
    NSDictionary *topRowTextAttributes = @{NSFontAttributeName : topRowFont };
    NSDictionary *bottomRowTextAttributes = @{NSFontAttributeName : bottomRowFont };
    
    [headerText setAttributes:topRowTextAttributes range:NSMakeRange(0, headerText.length)];
    [bottomText setAttributes:bottomRowTextAttributes range:NSMakeRange(0, bottomText.length)];
    
    [headerText appendAttributedString:bottomText];

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:2];
    [label setTextColor:[UIColor colorWithHexString:XASBrandMainColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.attributedText = headerText;
    self.navigationItem.titleView = label;
    

}

@end
