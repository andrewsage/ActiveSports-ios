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


@interface XASTodayHomeViewController () {
    
    NSMutableArray *_tagsArray;
    NSMutableDictionary *_collectionsDictionary;
}

@property (weak, nonatomic) IBOutlet UIButton *strengthButton;
@property (weak, nonatomic) IBOutlet UIButton *cardioButton;
@property (weak, nonatomic) IBOutlet UIButton *weightLossButton;
@property (weak, nonatomic) IBOutlet UIButton *flexibilityButton;
@property (weak, nonatomic) IBOutlet UIButton *resultsButton;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end

@implementation XASTodayHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tagsArray = [NSMutableArray arrayWithCapacity:0];
    
    // Do any additional setup after loading the view.
    
    self.strengthButton.layer.borderWidth = 1.0f;
    self.strengthButton.layer.cornerRadius = 2.0f;
    self.strengthButton.layer.borderColor = [UIColor blueColor].CGColor;

    self.cardioButton.layer.borderWidth = 1.0f;
    self.cardioButton.layer.cornerRadius = 2.0f;
    self.cardioButton.layer.borderColor = [UIColor blueColor].CGColor;
    
    self.weightLossButton.layer.borderWidth = 1.0f;
    self.weightLossButton.layer.cornerRadius = 2.0f;
    self.weightLossButton.layer.borderColor = [UIColor blueColor].CGColor;
    
    self.flexibilityButton.layer.borderWidth = 1.0f;
    self.flexibilityButton.layer.cornerRadius = 2.0f;
    self.flexibilityButton.layer.borderColor = [UIColor blueColor].CGColor;
    
    self.resultsButton.layer.cornerRadius = 2.0f;
    
    [self.resultsButton setBackgroundColor:[UIColor colorWithRed:0.169 green:0.655 blue:0.098 alpha:1]];
    [self.resultsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.title = @"Activties near you";
    
    
    self.mapView.delegate = self;
    MKUserTrackingBarButtonItem *buttonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    
    [self rebuildContent];
}


- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.090 green:0.161 blue:0.490 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.090 green:0.161 blue:0.490 alpha:1], NSForegroundColorAttributeName, nil];
    
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
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *weekdayComponents =
        [gregorian components:NSWeekdayCalendarUnit fromDate:today];
        NSInteger weekday = [weekdayComponents weekday] - 1;
        
        [searchDictionary setObject:[NSNumber numberWithInteger:weekday] forKey:@"dayOfWeek"];
        
        controller.viewType = XASOpportunitiesViewSearch;
        controller.searchDictionary = [NSDictionary dictionaryWithDictionary:searchDictionary];
    }
}

#pragma mark - Actions

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
        [sender setSelected:NO];
        sender.backgroundColor = [UIColor whiteColor];
        [_tagsArray removeObject:tag];
    } else {
        [sender setSelected:YES];
        sender.backgroundColor = [UIColor blueColor];
        [_tagsArray addObject:tag];
    }
    
    [self rebuildContent];
}

#pragma mark - Map stuff

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
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
            pinView.image = [UIImage imageNamed:@"location"];
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
        UILabel *numberView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pinView.frame.size.width, pinView.frame.size.height)];
        numberView.text = venueAnnotation.numberOfActivities;
        numberView.textAlignment = NSTextAlignmentCenter;
        numberView.font = [UIFont boldSystemFontOfSize:10.0f];
        numberView.textColor = [UIColor redColor];
        [pinView addSubview:numberView];
        
        return pinView;
    }
    return nil;
}

#pragma mark -

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
    
    for(NSString *key in venues.allKeys) {
        
        XASVenue *venue = [venues objectForKey:key];
        CLLocationCoordinate2D venueCoord = CLLocationCoordinate2DMake(venue.locationLat.doubleValue, venue.locationLong.doubleValue);
        
        XASVenueAnnotation *annotation = [[XASVenueAnnotation alloc] init];
        annotation.title = venue.name;
        NSMutableArray *objectsArray = [_collectionsDictionary objectForKey:venue.name];
        
        annotation.numberOfActivities = [NSString stringWithFormat:@"%d", objectsArray.count];
        annotation.coordinate = venueCoord;
        
        [self.mapView addAnnotation:annotation];
    }

}

@end
