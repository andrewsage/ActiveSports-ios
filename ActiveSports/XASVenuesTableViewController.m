//
//  XASVenuesTableViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 16/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASVenuesTableViewController.h"

#import "XASVenue.h"
#import "XASRegion.h"
#import "XASOpportunitiesTableViewController.h"
#import "Constants.h"
#import "UIColor+Expanded.h"
#import "XASVenueTableViewCell.h"
#import "XASVenueTableViewController.h"


@interface XASVenuesTableViewController () {
    NSMutableArray *objectsArray;
    CLLocationManager *locationManager;
    CLLocation *mCurrentLocation;
}


@end

@implementation XASVenuesTableViewController

- (void)rebuildContent {
    objectsArray = [NSMutableArray array];
    NSDictionary *dictionary = [XASVenue dictionary];
    for(NSString *key in dictionary.allKeys) {
        XASVenue *venue = [dictionary objectForKey:key];
        [objectsArray addObject:venue];
    }
    
    [objectsArray sortUsingComparator:^(XASVenue *venue1,
                                        XASVenue *venue2){
        
        return [venue1.name compare:venue2.name options:NSCaseInsensitiveSearch];
    }];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    [self rebuildContent];
    
    /*
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    UIFont *boldFont = [UIFont fontWithName:@"Arial-BoldMT"
                                       size:14];
    
    NSDictionary *boldTextAttributes = @{NSFontAttributeName : boldFont};
    
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:@"Pull down to refresh content"
                                           attributes:boldTextAttributes];
    
    
    self.refreshControl.attributedTitle = attributedText;
    
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
     */
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:XASBrandMainColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:XASBrandMainColor], NSForegroundColorAttributeName, nil];
    
    [super viewWillAppear:animated];
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
    XASVenueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"venue" forIndexPath:indexPath];
    
    XASVenue *venue = [objectsArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.nameLabel.text = venue.name;
    cell.addressLabel.text = venue.address;
    
    double distanceInMiles = venue.distanceInMeters.doubleValue / 1609.344;
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f miles", distanceInMiles];
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
    if ([[segue identifier] isEqualToString:@"venue"]) {
        
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        
        XASVenueTableViewController *controller = (XASVenueTableViewController*)[segue destinationViewController];
        
        NSIndexPath *currentSelection = [self.tableView indexPathForSelectedRow];
        
        XASVenue *venue = [objectsArray objectAtIndex:currentSelection.row];
        
        controller.venue = venue;
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
    
    [XASVenue fetchAllInBackgroundFor:region withBlock:^(NSArray *objects, NSError *error) {
        
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


#pragma mark - actions

- (IBAction)homePressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    /*
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     */
    //[errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    mCurrentLocation = newLocation;
    
    // Re-calculate distances
    for(XASVenue *venue in objectsArray) {
        
        CLLocationCoordinate2D venueCoord = CLLocationCoordinate2DMake(venue.locationLat.doubleValue, venue.locationLong.doubleValue);
        
        CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:venueCoord.latitude
                                                               longitude:venueCoord.longitude];
        
        CLLocationDistance distance = [mCurrentLocation distanceFromLocation:venueLocation];
        venue.distanceInMeters = [NSNumber numberWithInt:distance];
    }
    
    [self.tableView reloadData];
}


@end
