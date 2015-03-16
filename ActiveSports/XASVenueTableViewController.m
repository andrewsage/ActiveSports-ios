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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEEE"];
    NSString *todayName = [weekday stringFromDate:now];

    
    self.title = self.venue.name;
    NSMutableArray *array = [NSMutableArray arrayWithArray:[XASOpportunity forVenue:self.venue]];
    opportuntiesArray = [[NSMutableArray alloc] initWithCapacity:0];
    for(XASOpportunity *opportunity in array) {
        
        if([opportunity.dayOfWeek isEqualToString:todayName]) {
            [opportuntiesArray addObject:opportunity];
        }
    }
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return nil;
            break;
        case 1: {
            
            UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                         CGRectMake(0, 0, tableView.frame.size.width, 100.0)];
            sectionHeaderView.backgroundColor = [UIColor clearColor];
            
            
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            headerLabel.backgroundColor = [UIColor clearColor];
            headerLabel.textAlignment = NSTextAlignmentCenter;
            [headerLabel setFont:[UIFont fontWithName:XASFontLight size:48.0]];
            headerLabel.textColor = [UIColor blackColor];
            headerLabel.text = @"What's on today";
            headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            [sectionHeaderView addSubview:headerLabel];
            
            
            [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:sectionHeaderView
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            
            [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:sectionHeaderView
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            
            return sectionHeaderView;
        }
            
            break;
        default:
            return nil;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return 3;
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
    
    switch (section) {
        case 0:
            return nil;
            break;
            
        case 1:
            return @"What's on today";
            break;
            
        default:
            return nil;
            break;
    }
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
                    logoImageView.image = [UIImage imageNamed:self.venue.slug];
                    
                    if(logoImageView.image == nil) {
                        logoImageView.image = [UIImage imageNamed:@"sport-aberdeen"];

                    }
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
                    
                default:
                    break;
            }
            
            cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.bounds)/2.0, 0, CGRectGetWidth(cell.bounds)/2.0);
            return cell;
        }
            break;
            
            
        case 1:
        {
            
            XASOpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"opportunity" forIndexPath:indexPath];
            
            // Configure the cell...
            XASOpportunity *opportunity = [opportuntiesArray objectAtIndex:indexPath.row];
            
            cell.titleLabel.text = opportunity.name;
            cell.venueLabel.text = opportunity.venue.name;
            cell.timeLabel.text = [NSString stringWithFormat:@"%@-%@",
                                   opportunity.startTime,
                                   opportunity.endTime];
            cell.ratingView.editable = NO;
            cell.ratingView.padding = 0.0f;
            cell.ratingView.rate = opportunity.effortRating.floatValue;
            
            XASVenue *venue = [XASVenue venueWithObjectID:opportunity.venue.remoteID];
            double distanceInMiles = venue.distanceInMeters.doubleValue / 1609.344;
            if(distanceInMiles > 200) {
                cell.distanceLabel.text = @"> 200 miles";
            } else {
                cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f miles", distanceInMiles];
            }
            cell.distanceLabel.layer.cornerRadius = 2.0f;
            
            
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