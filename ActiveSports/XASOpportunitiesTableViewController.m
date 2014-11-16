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
    NSMutableArray *objectsArray;
    CLLocationManager *locationManager;
    CLLocation *mCurrentLocation;
}

@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;

@end

@implementation XASOpportunitiesTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        // Change button color
        //self.revealButtonItem.tintColor = [UIColor colorWithWhite:0.96f alpha:0.2f];
        
        // Set the gesture
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1];
    
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    objectsArray = [NSMutableArray array];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    UIFont *boldFont = [UIFont fontWithName:@"Arial-BoldMT"
                                       size:14];
    
    NSDictionary *boldTextAttributes = @{NSFontAttributeName : boldFont};
    
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:@"Pull down to refresh content"
                                           attributes:boldTextAttributes];

    
    self.refreshControl.attributedTitle = attributedText;
    
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEEE"];
    NSString *todayName = [weekday stringFromDate:now];
    
    objectsArray = [NSMutableArray array];
    NSDictionary *dictionary = [XASOpportunity dictionary];
    for(NSString *key in dictionary.allKeys) {
        XASOpportunity *opportunity = [dictionary objectForKey:key];
        if([opportunity.dayOfWeek isEqualToString:todayName]) {
            if(self.venue) {
                if([self.venue.remoteID isEqual:opportunity.venue.remoteID]) {
                    [objectsArray addObject:opportunity];
                }
                
            } else {
                [objectsArray addObject:opportunity];
            }
        }
    }
    
    [objectsArray sortUsingComparator:^(XASOpportunity *opportunity1,
                                        XASOpportunity *opportunity2){
        
        return [opportunity1.name compare:opportunity2.name options:NSCaseInsensitiveSearch];
    }];

    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return objectsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XASOpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"opportunity" forIndexPath:indexPath];
    
    XASOpportunity *opportunity = [objectsArray objectAtIndex:indexPath.row];
    // Configure the cell...
    
    cell.titleLabel.text = opportunity.name;
    cell.venueLabel.text = opportunity.venue.name;
    cell.timeLabel.text = [NSString stringWithFormat:@"%@-%@",
                              opportunity.startTime,
                              opportunity.endTime];
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
    region.remoteID = @"1";
    
    [XASOpportunity fetchAllInBackgroundFor:region withBlock:^(NSArray *objects, NSError *error) {
        
        if(error) {
            NSLog(@"error: %@", error.localizedDescription);
        } else {
            NSDate *now = [NSDate date];
            NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
            [weekday setDateFormat: @"EEEE"];
            NSString *todayName = [weekday stringFromDate:now];
            
            objectsArray = [NSMutableArray array];
            for(XASOpportunity *opportunity in objects) {
                if([opportunity.dayOfWeek isEqualToString:todayName]) {
                    [objectsArray addObject:opportunity];
                }
            }
            
            [objectsArray sortUsingComparator:^(XASOpportunity *opportunity1,
                                                XASOpportunity *opportunity2){
                
                return [opportunity1.name compare:opportunity2.name];
            }];
            
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
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    mCurrentLocation = newLocation;
    
    // Re-calculate distances
    for(XASOpportunity *opportunity in objectsArray) {
        
        CLLocationCoordinate2D venueCoord = CLLocationCoordinate2DMake(opportunity.venue.locationLat.doubleValue, opportunity.venue.locationLong.doubleValue);
        
        CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:venueCoord.latitude
                                                                 longitude:venueCoord.longitude];
        
        CLLocationDistance distance = [mCurrentLocation distanceFromLocation:venueLocation];
        opportunity.distanceInMeters = [NSNumber numberWithInt:distance];
    }
    
    [self.tableView reloadData];
}


@end
