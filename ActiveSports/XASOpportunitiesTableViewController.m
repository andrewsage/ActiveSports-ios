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
#import "UIColor+Expanded.h"
#import "Constants.h"
#import "XASDayHour.h"


@interface XASOpportunitiesTableViewController () {
    CLLocationManager *locationManager;
    CLLocation *mCurrentLocation;
    
    NSMapTable *_collectionsMapTable;
    NSMutableDictionary *_preferencesDictionary;
}

@property (weak, nonatomic) IBOutlet UIButton *saveSearchButton;
@property (weak, nonatomic) IBOutlet UIView *headerView;

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
    
    _preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(_preferencesDictionary == nil) {
        _preferencesDictionary = [NSMutableDictionary dictionary];
    }
    
    _collectionsMapTable = [NSMapTable new];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1];
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
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
            
        case XASOpportunitiesViewFavourites:
            self.title = @"Your favourites";
            break;
            
        case XASOpportunitiesViewSearch:
            self.title = @"Advanced Search";
            break;
            
        case XASOpportunitiesViewSavedSearch:
            self.title = [NSString stringWithFormat:@"Saved Search: %@", self.searchName];
            break;
            
        case XASOpportunitiesViewToday:
            self.title = @"What's on today";
            break;
            
        default:
            break;
    }
    
    //[self rebuildContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:XASBrandMainColor];
    
    if(self.viewType == XASOpportunitiesViewSearch) {
        self.tableView.tableHeaderView.hidden = NO;
    } else {
        self.tableView.tableHeaderView.hidden = YES;
        self.tableView.tableHeaderView = nil;
    }
    
    _preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(_preferencesDictionary == nil) {
        _preferencesDictionary = [NSMutableDictionary dictionary];
    }
    
    [self rebuildContent];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)buildTimeSortedCollection:(NSArray *)opportunities {
    
    if(_collectionsMapTable == nil) {
        _collectionsMapTable = [NSMapTable new];
    }
    [_collectionsMapTable removeAllObjects];
    
    for(XASOpportunity *opportunity in opportunities) {
        
        NSArray *startTimeComponents = [opportunity.startTime componentsSeparatedByString:@":"];
        NSInteger startHour = [[startTimeComponents objectAtIndex:0] integerValue];

        XASDayHour *dayHour = [[XASDayHour alloc] init];
        dayHour.hourOfDay = [NSNumber numberWithInteger:startHour];
        dayHour.dayOfWeek = [NSNumber numberWithInteger:opportunity.dayOfWeekNumber.integerValue];
        
        // Find a XASDayHour key that matches the hour and day we have
        for(XASDayHour *dayHourKey in [_collectionsMapTable keyEnumerator].allObjects) {
            if([dayHour isEqual:dayHourKey]) {
                dayHour = dayHourKey;
                break;
            }
        }
        
        NSMutableArray *objectsArray = [_collectionsMapTable objectForKey:dayHour];
        
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
        [_collectionsMapTable setObject:objectsArray forKey:dayHour];
     }
}

- (void)updateTitle:(NSInteger)numberOfActivities {
    NSMutableAttributedString *headerText = [[NSMutableAttributedString alloc] initWithString:self.title];
    NSMutableAttributedString *bottomText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%ld Activities", (long)numberOfActivities]];
    
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

- (void)rebuildContent {
    
    NSInteger numberOfActivities = 0;
    
    switch (self.viewType) {
        case XASOpportunitiesViewAll:
            break;
            
        case XASOpportunitiesViewFavourites:
        {
            
            NSArray *opportunities = [XASOpportunity forFavourites];
            numberOfActivities = opportunities.count;
            [self buildTimeSortedCollection:opportunities];
            
        }
            break;
            
        case XASOpportunitiesViewSearch:
        case XASOpportunitiesViewSavedSearch:
        {
            
            NSArray *opportunities = [XASOpportunity forSearch:self.searchDictionary];
            numberOfActivities = opportunities.count;
            [self buildTimeSortedCollection:opportunities];
            
        }
            break;
            
        case XASOpportunitiesViewToday:
        {
            
            NSArray *opportunities = [XASOpportunity forTodayWithSearch:self.searchDictionary];
            numberOfActivities = opportunities.count;
            [self buildTimeSortedCollection:opportunities];
        }
            break;
            
        default:
            break;
    }
    
    [self updateTitle:numberOfActivities];
}

- (NSArray*)sortedKeys {
    
    NSSortDescriptor *daySD = [NSSortDescriptor sortDescriptorWithKey:@"dayOfWeek" ascending:YES];
    NSSortDescriptor *hourSD = [NSSortDescriptor sortDescriptorWithKey:@"hourOfDay" ascending:YES];
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[[_collectionsMapTable keyEnumerator].allObjects sortedArrayUsingDescriptors:@[daySD, hourSD]]];
    
    return sortedArray;
}

#pragma mark - Actions

- (IBAction)homePressed:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)saveSearchTapped:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Name the search"
                                                                   message:@"This is the name the search will be saved under."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name of search";
    }];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UITextField *titleField =                                                       alert.textFields.firstObject;
                                                              
                                                              [self.saveSearchButton setImage:[UIImage imageNamed:@"save-search-active"] forState:UIControlStateNormal];
                                                              
                                                              self.tableView.tableHeaderView.hidden = YES;
                                                              self.tableView.tableHeaderView = nil;

                                                              
                                                              NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                                                              NSString *searchQueriesPath = [documentDirectory stringByAppendingPathExtension:@"searches"];
                                                              
                                                              
                                                              NSMutableDictionary *searchQueriesDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:searchQueriesPath];
                                                              
                                                              if(searchQueriesDictionary == nil) {
                                                                  searchQueriesDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
                                                              }
                                                              
                                                              [searchQueriesDictionary setObject:self.searchDictionary forKey:titleField.text];
                                                              
                                                              [searchQueriesDictionary writeToFile:searchQueriesPath atomically:YES];

                                                          }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(_collectionsMapTable.count == 0) {
        return 1;
    }

    return _collectionsMapTable.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(_collectionsMapTable.count == 0) {
        return nil;
    }
    
    XASDayHour *dayHour = [[self sortedKeys] objectAtIndex:section];

    NSString *heading = [NSString stringWithFormat:@"%@", [dayHour asString]];
    
    return heading;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(_collectionsMapTable.count == 0) {
        return 1;
    }
    
    NSArray *objectsArray = [_collectionsMapTable objectForKey:[[self sortedKeys] objectAtIndex:section]];
    return objectsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_collectionsMapTable.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        if(self.viewType == XASOpportunitiesViewSearch) {
            cell.textLabel.text = @"No activites match your search criteria. Please try again with other options.";
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        } else {
            cell.textLabel.text = @"No records to display";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        return cell;
    }
    
    XASOpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"opportunity" forIndexPath:indexPath];
    
    NSArray *objectsArray = [_collectionsMapTable objectForKey:[[self sortedKeys] objectAtIndex:indexPath.section]];

    XASOpportunity *opportunity = [objectsArray objectAtIndex:indexPath.row];
    cell.opportunity = opportunity;
    
    NSNumber *included = [_preferencesDictionary objectForKey:opportunity.remoteID];
    if(included.boolValue) {
        cell.favouriteImageView.image = [UIImage imageNamed:@"favourite-activity-selected"];
    } else {
        cell.favouriteImageView.image = [UIImage imageNamed:@"favourite-activity"];
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return self.viewType == XASOpportunitiesViewFavourites;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSMutableArray *objectsArray = [_collectionsMapTable objectForKey:[[self sortedKeys] objectAtIndex:indexPath.section]];

        XASOpportunity *opportunity = [objectsArray objectAtIndex:indexPath.row];
        [_preferencesDictionary removeObjectForKey:opportunity.remoteID];
        
        [objectsArray removeObjectAtIndex:indexPath.row];
        [_collectionsMapTable setObject:objectsArray forKey:[[self sortedKeys] objectAtIndex:indexPath.section]];
        
        if([NSKeyedArchiver archiveRootObject:_preferencesDictionary toFile:[self preferencesFilepath]]) {
        } else {
            NSLog(@"Failed to save dictionary");
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if(objectsArray.count == 0) {
            [_collectionsMapTable removeObjectForKey:[[self sortedKeys] objectAtIndex:indexPath.section]];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            
        }
    }
}

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
        
        NSArray *objectsArray = [_collectionsMapTable objectForKey:[[self sortedKeys] objectAtIndex:currentSelection.section]];
        
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
    /*
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     */
    //[errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    mCurrentLocation = newLocation;
    
    // Re-calculate distances to the venues
    NSDictionary *dictionary = [XASVenue dictionary];
    for(NSString *key in dictionary.allKeys) {
        XASVenue *venue = [dictionary objectForKey:key];
        
        CLLocationCoordinate2D venueCoord = CLLocationCoordinate2DMake(venue.locationLat.doubleValue, venue.locationLong.doubleValue);
        
        CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:venueCoord.latitude
                                                               longitude:venueCoord.longitude];
        
        CLLocationDistance distance = [mCurrentLocation distanceFromLocation:venueLocation];
        venue.distanceInMeters = [NSNumber numberWithInt:distance];
        
        [dictionary setValue:venue forKey:venue.remoteID];
    }
    
    [XASVenue saveDictionary];
    
    // Only reload the table if we are not in edit mode
    if(self.tableView.editing == NO) {
        [self.tableView reloadData];
    }
}

#pragma mark - Preferences
- (NSString*)preferencesFilepath {
    
    NSString *documentsDir = [XASBaseObject cacheDirectory];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"favourites"]];
    
    return path;
}



@end
