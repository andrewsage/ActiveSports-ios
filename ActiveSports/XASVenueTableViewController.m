//
//  XASVenueTableViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 14/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASVenueTableViewController.h"
#import "UIColor+Expanded.h"
#import "Constants.h"
#import "XASOpportunity.h"
#import "XASOpportunityTableViewCell.h"
#import "XASOpportunityViewController.h"



@interface XASVenueTableViewController () {
    
    NSMutableArray *opportuntiesArray;
}

@end

@implementation XASVenueTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.venue.name;
    
    NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];
    [searchDictionary setValue:self.venue.remoteID forKey:@"venue"];
        
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:NSCalendarUnitWeekday fromDate:today];
    NSInteger weekday = [weekdayComponents weekday] - 1;
    
    [searchDictionary setObject:[NSNumber numberWithInteger:weekday] forKey:@"dayOfWeek"];
    
    opportuntiesArray = [NSMutableArray arrayWithArray:[XASOpportunity forSearch:searchDictionary]];
    
    [opportuntiesArray sortUsingComparator:^(XASOpportunity *opportunity1,
                                        XASOpportunity *opportunity2){
        
        return [opportunity1.name compare:opportunity2.name options:NSCaseInsensitiveSearch];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:XASBrandMainColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)homePressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)websitePressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.venue.website]];
}

- (IBAction)phonePressed:(id)sender {
    NSString *formattedPhone = [NSString stringWithFormat:@"telprompt://%@", [self.venue.phone stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:formattedPhone]];
    
}

- (IBAction)addressPressed:(id)sender {
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.venue.locationLat.doubleValue, self.venue.locationLong.doubleValue);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.venue.name];
    
    CLLocation *addressLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                             longitude:coordinate.longitude];
    
    // Create a region centered on the starting point with a 10km span
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(addressLocation.coordinate, 10000, 10000);
    
    // Open the item in Maps, specifying the map region to display.
    [MKMapItem openMapsWithItems:[NSArray arrayWithObject:mapItem]
                   launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapCenterKey,
                                  [NSValue valueWithMKCoordinateSpan:region.span], MKLaunchOptionsMapSpanKey, nil]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return 5;
            break;
            
        case 1:
            return opportuntiesArray.count;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 86;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    height = 120;
                    break;
                    
                case 1:
                    height = 44;
                    break;
                    
                case 2:
                    height = 100;
                    break;
                    
                case 3: // Map
                    height = 150;
                    break;
                    
                case 4:
                    height = 100;
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 1:
            height = 86;
            break;
            
        default:
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //
    
    switch (indexPath.section) {
        case 0:
        {
            UITableViewCell *cell;
            
            switch (indexPath.row) {
                case 0: {
                    
                    cell = [tableView dequeueReusableCellWithIdentifier:@"logo" forIndexPath:indexPath];
                    UIImageView *logoImageView = (UIImageView*)[cell viewWithTag:1];
                    logoImageView.image = [UIImage imageNamed:self.venue.venueOwner.slug];
                }
                    
                    break;
                    
                case 1: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"name" forIndexPath:indexPath];

                    UILabel *label = (UILabel*)[cell viewWithTag:1];
                    label.text = self.venue.name;
                }
                    break;
                    
                case 2: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"contact" forIndexPath:indexPath];
                    
                    UILabel *addressLabel = (UILabel*)[cell viewWithTag:1];
                    UILabel *telephoneLabel = (UILabel*)[cell viewWithTag:2];
                    UILabel *webLabel = (UILabel*)[cell viewWithTag:3];
                    
                    addressLabel.text = [NSString stringWithFormat:@"%@, %@",
                                         self.venue.address,
                                         self.venue.postCode];
                    
                    telephoneLabel.text = self.venue.phone;
                    webLabel.text = self.venue.website;
                }
                    break;
                    
                case 3: // Map
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"map" forIndexPath:indexPath];
                    
                    MKMapView *mapView = (MKMapView*)[cell viewWithTag:1];
                    
                    mapView.delegate = self;
                    
                    
                    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                    point.coordinate = CLLocationCoordinate2DMake(self.venue.locationLat.doubleValue, self.venue.locationLong.doubleValue);
                    point.title = self.venue.name;
                    
                    [mapView addAnnotation:point];
                    
                    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
                    
                    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.venue.locationLat.doubleValue, self.venue.locationLong.doubleValue);
                    
                    [mapView setRegion:[mapView regionThatFits:MKCoordinateRegionMake(center, span)] animated:NO];
                    
                }
                    break;
                    
                case 4: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"whatsonheader" forIndexPath:indexPath];
                }
                    break;
                    
                default:
                    break;
            }
            
            cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.bounds)/2.0, 0, CGRectGetWidth(cell.bounds)/2.0);
            return cell;
        }
            break;
            
            
        case 1: {
            XASOpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"opportunity" forIndexPath:indexPath];
            
            XASOpportunity *opportunity = [opportuntiesArray objectAtIndex:indexPath.row];
            cell.opportunity = opportunity;
            
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
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
        
        XASOpportunity *opportunity = [opportuntiesArray objectAtIndex:currentSelection.row];
        controller.opportunity = opportunity;
        
    }
}


@end
