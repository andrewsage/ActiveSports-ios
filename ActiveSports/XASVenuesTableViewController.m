//
//  XASVenuesTableViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 16/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASVenuesTableViewController.h"

#import "SWRevealViewController.h"
#import "XASVenue.h"
#import "XASOpportunitiesTableViewController.h"


@interface XASVenuesTableViewController () {
    NSMutableArray *objectsArray;
    CLLocationManager *locationManager;
    CLLocation *mCurrentLocation;
}


@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;


@end

@implementation XASVenuesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;

    
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
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    objectsArray = [NSMutableArray array];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"venue" forIndexPath:indexPath];
    
    XASVenue *venue = [objectsArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = venue.name;
    double distanceInMiles = venue.distanceInMeters.doubleValue / 1609.344;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f miles", distanceInMiles];
    
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
        
        
        XASOpportunitiesTableViewController *controller = (XASOpportunitiesTableViewController*)[segue destinationViewController];
        
        NSIndexPath *currentSelection = [self.tableView indexPathForSelectedRow];
        
        XASVenue *venue = [objectsArray objectAtIndex:currentSelection.row];
        
        controller.venue = venue;
        controller.viewType = XASOpportunitiesViewVenue;
    }

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
