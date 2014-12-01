//
//  XASOpportunitiesTableViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 18/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASOpportunitiesTableViewController.h"
#import "XASOpportunity.h"
#import "XASRegion.h"
#import "XASOpportunityTableViewCell.h"
#import "XASOpportunityDetailsViewController.h"
#import "XASOpportunityViewController.h"

#import "SWRevealViewController.h"


@interface XASOpportunitiesTableViewController () {
    CLLocationManager *locationManager;
    CLLocation *mCurrentLocation;
    
    NSMutableDictionary *_collectionNamesDictionary;
    NSMutableDictionary *_collectionsDictionary;
}

@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;

@end

@implementation XASOpportunitiesTableViewController

- (id) initWithCoder:(NSCoder *) coder {
    self = [super initWithCoder:coder];
    if(self) {
        
        _viewType = XASOpportunitiesViewAll;

    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionsDictionary = [NSMutableDictionary dictionary];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        // Change button color
        //self.revealButtonItem.tintColor = [UIColor colorWithWhite:0.96f alpha:0.2f];
        
        // Set the gesture
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( rightRevealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1];
    
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    UIFont *boldFont = [UIFont fontWithName:@"Arial-BoldMT"
                                       size:14];
    
    NSDictionary *boldTextAttributes = @{NSFontAttributeName : boldFont};
    
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:@"Pull down to refresh content"
                                           attributes:boldTextAttributes];

    
    self.refreshControl.attributedTitle = attributedText;
    
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    switch (self.viewType) {
        case XASOpportunitiesViewAll:
            self.title = @"What's on today";
            break;
            
        case XASOpportunitiesViewVenue:
            self.title = @"What's on today";
            break;
            
        case XASOpportunitiesViewLikes:
            self.title = @"What's on today that you like";
            break;
            
        case XASOpportunitiesViewSearch:
            self.title = @"Search Results";
            break;
            
        default:
            break;
    }
    
    [self rebuildContent];

    
    //[self refreshContent];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)rebuildContent {
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEEE"];
    NSString *todayName = [weekday stringFromDate:now];
    
    
    NSDictionary *dictionary = [XASOpportunity dictionary];
    for(NSString *key in dictionary.allKeys) {
        XASOpportunity *opportunity = [dictionary objectForKey:key];
        
        if([opportunity.dayOfWeek isEqualToString:todayName]
           || self.viewType == XASOpportunitiesViewSearch) {
            
            BOOL include = YES;
            NSArray *startTimeComponents = [opportunity.startTime componentsSeparatedByString:@":"];
            NSInteger startHour = [[startTimeComponents objectAtIndex:0] integerValue];
            
            switch (self.viewType) {
                case XASOpportunitiesViewAll:
                    break;
                    
                case XASOpportunitiesViewVenue:
                    if([self.venue.remoteID isEqual:opportunity.venue.remoteID] == NO) {
                        include = NO;
                    }
                    break;
                    
                case XASOpportunitiesViewLikes: {
                    
                    NSDictionary *preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
                    
                    if(preferencesDictionary == nil) {
                        preferencesDictionary = [NSDictionary dictionary];
                    }
                    
                    NSNumber *likes = [preferencesDictionary objectForKey:opportunity.activityID];
                    if(likes) {
                        if(likes.boolValue == NO) {
                            include = NO;
                        }
                    }
                }
                    break;
                    
                case XASOpportunitiesViewSearch: {
                    NSArray *dayNameArray = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
                    NSNumber *dayOfWeekNumber = [self.searchDictionary objectForKey:@"dayOfWeek"];
                    NSString *dayName = [dayNameArray objectAtIndex:dayOfWeekNumber.integerValue];
                    NSNumber *timeOfDayNumber = [self.searchDictionary objectForKey:@"timeOfDay"];
                    
                    NSNumber *minimumExertion = [self.searchDictionary objectForKey:@"minimumExertion"];
                    NSNumber *maximumExertion = [self.searchDictionary objectForKey:@"maximumExertion"];
                    
                    if([self.searchDictionary objectForKey:@"tag"]) {
                        BOOL matches = NO;
                        for(NSString *tag in [self.searchDictionary objectForKey:@"tag"]) {
                            if([opportunity.tagsArray containsObject:tag]) {
                                matches = YES;
                            }
                        }
                        if(matches == NO) {
                            include = NO;
                        }
                    }
                    
                    if(opportunity.effortRating < minimumExertion && [self.searchDictionary objectForKey:@"minimumExertion"]) {
                        include = NO;
                    }
                    
                    if(opportunity.effortRating > maximumExertion && [self.searchDictionary objectForKey:@"maximumExertion"]) {
                        include = NO;
                    }
                    
                    if([self.searchDictionary objectForKey:@"timeOfDay"]) {
                        switch (timeOfDayNumber.integerValue) {
                            case 0: // Morning 00:00 - 11:59
                                if(startHour >= 12) {
                                    include = NO;
                                }
                                break;
                                
                            case 1: // Afternoon 12:00 - 16:59
                                if(startHour < 12 || startHour >= 17) {
                                    include = NO;
                                }
                                break;
                                
                            case 2: // Evening 17:00 - 23:59
                                if(startHour < 17) {
                                    include = NO;
                                }
                                break;
                                
                            default:
                                break;
                        }
                    }
                    
                    if([opportunity.dayOfWeek isEqualToString:dayName] == NO && [self.searchDictionary objectForKey:@"dayOfWeek"]) {
                        include = NO;
                    }
                }
                    break;
                    
                    
                default:
                    break;
            }
            
            if(include) {
                NSMutableArray *objectsArray = [_collectionsDictionary objectForKey:[NSNumber numberWithInteger:startHour]];
                
                if(objectsArray == nil) {
                    objectsArray = [NSMutableArray array];
                }
                
                [objectsArray addObject:opportunity];
                
                [objectsArray sortUsingComparator:^(XASOpportunity *opportunity1,
                                                    XASOpportunity *opportunity2){
                    
                    return [opportunity1.name compare:opportunity2.name options:NSCaseInsensitiveSearch];
                }];
                
                
                [objectsArray sortUsingComparator:^(XASOpportunity *opportunity1,
                                                    XASOpportunity *opportunity2){
                    
                    return [opportunity1.startTime compare:opportunity2.startTime options:NSCaseInsensitiveSearch];
                }];
                
                [_collectionsDictionary setObject:objectsArray forKey:[NSNumber numberWithInteger:startHour]];
            }
        }
    }
}

- (NSArray*)sortedKeys {
    NSMutableArray *keysArray = [NSMutableArray arrayWithArray:_collectionsDictionary.allKeys];
    [keysArray sortUsingComparator:^(NSNumber *number1, NSNumber *number2) {
        return [number1 compare:number2];
    }];
    
    return keysArray;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return _collectionsDictionary.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSNumber *hour = [[self sortedKeys] objectAtIndex:section];

    NSString *heading = [NSString stringWithFormat:@"%02ld:00", (long)hour.integerValue];
    
    return heading;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSArray *objectsArray = [_collectionsDictionary objectForKey:[[self sortedKeys] objectAtIndex:section]];
    return objectsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XASOpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"opportunity" forIndexPath:indexPath];
    
    NSArray *objectsArray = [_collectionsDictionary objectForKey:[[self sortedKeys] objectAtIndex:indexPath.section]];

    XASOpportunity *opportunity = [objectsArray objectAtIndex:indexPath.row];
    // Configure the cell...
    
    cell.titleLabel.text = opportunity.name;
    cell.venueLabel.text = opportunity.venue.name;
    if(self.viewType == XASOpportunitiesViewSearch) {
        cell.timeLabel.text = [NSString stringWithFormat:@"%@ %@-%@",
                               opportunity.dayOfWeek,
                               opportunity.startTime,
                               opportunity.endTime];
    } else {
        cell.timeLabel.text = [NSString stringWithFormat:@"%@-%@",
                               opportunity.startTime,
                               opportunity.endTime];
    }
    cell.ratingView.editable = NO;
    cell.ratingView.padding = 0.0f;
    cell.ratingView.rate = opportunity.effortRating.floatValue;
    double distanceInMiles = opportunity.distanceInMeters.doubleValue / 1609.344;
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f miles", distanceInMiles];
    
    cell.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"details"]) {
        
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

        
        XASOpportunityViewController *controller = (XASOpportunityViewController*)[segue destinationViewController];
        
        NSIndexPath *currentSelection = [self.tableView indexPathForSelectedRow];
        
        NSArray *objectsArray = [_collectionsDictionary objectForKey:[[self sortedKeys] objectAtIndex:currentSelection.section]];
        
        XASOpportunity *opportunity = [objectsArray objectAtIndex:currentSelection.row];
        controller.opportunity = opportunity;
        
    }
}

- (void)refreshTable {
    
    UIFont *boldFont = [UIFont fontWithName:@"Arial-BoldMT"
                                       size:14];
    
    NSDictionary *boldTextAttributes = @{NSFontAttributeName : boldFont};
    
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:@"Downloading content"
                                           attributes:boldTextAttributes];
    
    
    self.refreshControl.attributedTitle = attributedText;

    [self refreshContent];
}


- (void)refreshContent {
    XASRegion *region = [[XASRegion alloc] init];
    region.remoteID = @"4";
    
    [XASOpportunity fetchAllInBackgroundFor:region withBlock:^(NSArray *objects, NSError *error) {
        
        if(error) {
            NSLog(@"error: %@", error.localizedDescription);
        } else {
            [self rebuildContent];            
            [self.tableView reloadData];
        }
        
        [self.refreshControl endRefreshing];
        
        UIFont *boldFont = [UIFont fontWithName:@"Arial-BoldMT"
                                           size:14];
        
        NSDictionary *boldTextAttributes = @{NSFontAttributeName : boldFont};
        
        
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:@"Pull down to refresh content"
                                               attributes:boldTextAttributes];
        
        
        self.refreshControl.attributedTitle = attributedText;


        
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    mCurrentLocation = newLocation;
    
    /*
    // Re-calculate distances
    for(XASOpportunity *opportunity in objectsArray) {
        
        CLLocationCoordinate2D venueCoord = CLLocationCoordinate2DMake(opportunity.venue.locationLat.doubleValue, opportunity.venue.locationLong.doubleValue);
        
        CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:venueCoord.latitude
                                                                 longitude:venueCoord.longitude];
        
        CLLocationDistance distance = [mCurrentLocation distanceFromLocation:venueLocation];
        opportunity.distanceInMeters = [NSNumber numberWithInt:distance];
    }
    */
    [self.tableView reloadData];
}

#pragma mark - Preferences
- (NSString*)preferencesFilepath {
    
    
    NSString *documentsDir = [XASBaseObject cacheDirectory];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"profile"]];
    
    return path;
}


@end
