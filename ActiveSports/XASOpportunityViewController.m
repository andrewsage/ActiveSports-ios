//
//  XASOpportunityViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 01/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASOpportunityViewController.h"
#import "XASRateViewController.h"
#import "XASVenueNotice.h"
#import "XASRateView.h"
#import "UIImage+Resize.h"
#import "UIColor+Expanded.h"
#import "Constants.h"

@interface XASOpportunityViewController () {
    NSMutableArray *_venueNotices;
    BOOL _hideImage;
    BOOL _favourite;
    NSMutableDictionary *_preferencesDictionary;

}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@end

@implementation XASOpportunityViewController

- (NSURL*)applicationDataDirectory {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleID];
    };
    
    NSError *error;
    if (![sharedFM fileExistsAtPath:appDirectory.path]) {
        [sharedFM createDirectoryAtURL:appDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        [self addSkipBackupAttributeToItemAtURL:appDirectory];
        NSLog(@"%@", error);
    }
    
    
    return appDirectory;
}


- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:XASBrandMainColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    

    /*
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.090 green:0.161 blue:0.490 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.090 green:0.161 blue:0.490 alpha:1], NSForegroundColorAttributeName, nil];
    
     */
    [super viewWillAppear:animated];
    
    _hideImage = NO;
    
    if([self.opportunity.imageURL isKindOfClass:[NSNull class]]) {
        _hideImage = YES;
    } else if([self.opportunity.imageURL isEqualToString:@""]) {
        _hideImage = YES;
    }
    
    if(_hideImage) {
        self.imageHeightConstraint.constant = 0.0f;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(_preferencesDictionary == nil) {
        _preferencesDictionary = [NSMutableDictionary dictionary];
    }
    
    self.title = self.opportunity.name;
    
    _favourite = NO;
    
    _hideImage = NO;
    
    if([self.opportunity.imageURL isKindOfClass:[NSNull class]]) {
        _hideImage = YES;
    } else if([self.opportunity.imageURL isEqualToString:@""]) {
        _hideImage = YES;
    }
    
    if(_hideImage) {
        self.imageHeightConstraint.constant = 0.0f;
    }

    
    _venueNotices = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary *dictionary = [XASVenueNotice dictionary];
    for(NSString *key in dictionary.allKeys) {
        XASVenueNotice *venueNotice = [dictionary objectForKey:key];
        
        if(venueNotice.venue.remoteID == self.opportunity.venue.remoteID) {
            [_venueNotices addObject:venueNotice];
        }
    }
    
    [_venueNotices sortUsingComparator:^(XASVenueNotice *notice1,
                                        XASVenueNotice *notice2){
        
        return [notice2.starts compare:notice1.starts];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)favouriteTapped:(id)sender {
    
    _favourite = !_favourite;
    
    NSNumber *included = [_preferencesDictionary objectForKey:self.opportunity.remoteID];
    if(included.boolValue) {
        [_preferencesDictionary setObject:[NSNumber numberWithBool:NO] forKey:self.opportunity.remoteID];
    } else {
        [_preferencesDictionary setObject:[NSNumber numberWithBool:YES] forKey:self.opportunity.remoteID];
    }
    
    if([NSKeyedArchiver archiveRootObject:_preferencesDictionary toFile:[self preferencesFilepath]]) {
    } else {
        NSLog(@"Failed to save dictionary");
    }

    
    NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
}


- (IBAction)homePressed:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)notificationsPressed:(id)sender {
    NSLog(@"go to notifications");
    
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView scrollToRowAtIndexPath:scrollIndexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (IBAction)websitePressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.opportunity.venue.website]];
}

- (IBAction)phonePressed:(id)sender {
    NSString *formattedPhone = [NSString stringWithFormat:@"telprompt://%@", [self.opportunity.venue.phone stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:formattedPhone]];

}

- (IBAction)addressPressed:(id)sender {
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.opportunity.venue.locationLat.doubleValue, self.opportunity.venue.locationLong.doubleValue);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.opportunity.venue.name];
    
    
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return nil;
            break;
        case 1: {
            
            UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                         CGRectMake(0, 0, tableView.frame.size.width, 50.0)];
            sectionHeaderView.backgroundColor = [UIColor clearColor];
            
            
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            headerLabel.backgroundColor = [UIColor clearColor];
            headerLabel.textAlignment = NSTextAlignmentLeft;
            [headerLabel setFont:[UIFont fontWithName:XASFontBold size:15.0]];
            headerLabel.textColor = [UIColor colorWithHexString:XASNegativeActionColor];
            headerLabel.text = @"NOTICES";
            headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            [sectionHeaderView addSubview:headerLabel];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notices-red"]];
            imageView.center = CGPointMake(15, headerLabel.center.y);
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [sectionHeaderView addSubview:imageView];
            
            [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:sectionHeaderView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0
                                                                           constant:10.0]];
            
            [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:sectionHeaderView
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1.0
                                                                           constant:10.0]];
            
            [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:imageView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0
                                                                           constant:8.0]];
            
            [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:imageView
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
    return _venueNotices.count > 0 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 9;
            break;
            
        case 1:
            return _venueNotices.count;
            break;
    }
    return  6;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            break;
            
        case 1:
            return @"NOTICES";
            break;
    }
    
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44.0f;
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: // Disclaimer
                {
                    height = 80.0f;
                }
                    break;
                case 1: // image
                    if(_hideImage) {
                        height = 0.0f;
                    } else {
                        height = 150.0f;
                    }
                    break;
                    
                case 2: // title
                    height = 100.0f;
                    break;
                    
                case 3: // notices indictor
                    height = _venueNotices.count > 0 ? 30.0f : 0.0f;
                    break;
                    
                case 4: // Rating
                {
                    height = 60.0f;
                }
                    break;
                    
                case 5: // description
                {
                    if([self.opportunity.opportunityDescription isEqualToString:@""]) {
                        height = 0;
                    } else {
                        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
                        
                        NSAttributedString *description = [self buildAttributedString:self.opportunity.opportunityDescription];
                        
                        
                        textView.attributedText = description;
                        
                        CGSize size = [textView sizeThatFits:CGSizeMake(tableView.frame.size.width, FLT_MAX)];
                        height = size.height;
                    }
                }
                    break;
                    
                case 6: // Tags
                    height = 44.0f;
                    break;
                    
                case 7: // Address
                    height = 100.0f;
                    break;
                    
                case 8: // map
                    height = 150.0f;
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 1: {
            
            XASVenueNotice *venueNotice = [_venueNotices objectAtIndex:indexPath.row];

            
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
            
            NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithAttributedString:[self buildAttributedString:venueNotice.message]];
            
            textView.attributedText = description;
            
            CGSize size = [textView sizeThatFits:CGSizeMake(tableView.frame.size.width, FLT_MAX)];
            height = size.height + 30;
            
        }
            break;
    }
    
    return height;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSAttributedString *)buildAttributedString:(NSString*)sourceString {
    NSMutableAttributedString *descriptionText = [[NSMutableAttributedString alloc] initWithData:[sourceString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                         options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                   NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                                              documentAttributes:nil error:nil];
    
    
    UIFont *bodyFont = [UIFont fontWithName:XASFontRegular
                                       size:12];
    
    NSDictionary *bodyTextAttributes = @{NSFontAttributeName : bodyFont};
    
    [descriptionText setAttributes:bodyTextAttributes range:NSMakeRange(0, descriptionText.length)];
    
    
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithString:@""];
    
    [description appendAttributedString:descriptionText];
    
    
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    return description;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"";
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    identifier = @"disclaimer";
                    break;
                case 1:
                    identifier = @"image";
                    break;

                case 2:
                    identifier = @"cell1";
                    break;
                case 3:
                    identifier = @"notifications";
                    break;
                    
                case 4:
                    identifier = @"cell2";
                    break;
                case 5:
                    identifier = @"cell3";
                    break;
                case 6:
                    identifier = @"cell4";
                    break;
                case 7:
                    identifier = @"cell5";
                    break;
                case 8:
                    identifier = @"cell6";
                    break;
            }
        }
            break;
            
        case 1:
            identifier = @"venueNotice";
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 1: {
                    if(_hideImage == NO) {
                        UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
                        
                        NSURLSession *session = [NSURLSession sharedSession];
                        NSArray *arr = [self.opportunity.imageURL componentsSeparatedByString:@"\""];
                        NSURL *imageURL;
                        if(arr.count > 1) {
                            imageURL = [NSURL URLWithString:arr[1]];
                        }
                        
                        NSString *cachedImageFileName = [NSString stringWithFormat:@"%@.png", self.opportunity.remoteID];
                        
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSURL *cachedImageURL = [[self applicationDataDirectory] URLByAppendingPathComponent:cachedImageFileName];
                        
                        if([fileManager fileExistsAtPath:cachedImageURL.absoluteString]) {
                            imageView.image = [UIImage imageWithContentsOfFile:cachedImageURL.absoluteString];
                        } else {
                            
                            [[session dataTaskWithURL:imageURL
                                    completionHandler:^(NSData *data,
                                                        NSURLResponse *response,
                                                        NSError *error) {
                                        if(error) {
                                            NSLog(@"error downloading from %@", self.opportunity.imageURL);
                                        } else {
                                            
                                            NSError *err = nil;
                                            NSString *cachedImageFileName = [NSString stringWithFormat:@"%@.png", self.opportunity.remoteID];
                                            
                                            NSFileManager *fileManager = [NSFileManager defaultManager];
                                            NSURL *cachedImageURL = [[self applicationDataDirectory] URLByAppendingPathComponent:cachedImageFileName];
                                            
                                            [fileManager removeItemAtPath:cachedImageURL.path error:&err];
                                            if ([data writeToURL:cachedImageURL atomically:YES])
                                            {
                                                NSLog(@"File is saved to =%@",cachedImageURL);
                                            }
                                            else
                                            {
                                                NSLog(@"failed to move: %@",[err userInfo]);
                                            }
                                            
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:cachedImageURL]];
                                                
                                                imageView.image = image;
                                                
                                            });
                                            
                                        }
                                        
                                    }] resume];
                        }
                    }


                }
                    
                    break;
                    
                case 2: {
                    UILabel *opportunityNameLabel = (UILabel*)[cell viewWithTag:2];
                    UILabel *whenLabel = (UILabel*)[cell viewWithTag:4];
                    UILabel *venueLabel = (UILabel*)[cell viewWithTag:3];
                    UIImageView *favouriteImageView = (UIImageView*)[cell viewWithTag:5];
                    
                    opportunityNameLabel.text = self.opportunity.name;
                    whenLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",
                                      self.opportunity.dayOfWeek,
                                      self.opportunity.startTime,
                                      self.opportunity.endTime];
                    venueLabel.text = self.opportunity.venue.name;
                    
                    NSNumber *included = [_preferencesDictionary objectForKey:self.opportunity.remoteID];

                    
                    if(included.boolValue) {
                        favouriteImageView.image = [UIImage imageNamed:@"favourite-activity-selected"];
                    } else {
                        favouriteImageView.image = [UIImage imageNamed:@"favourite-activity"];
                    }
                }
                    
                    break;
                    
                case 3: {
                    cell.backgroundColor = [UIColor colorWithHexString:XASNegativeActionColor];
                    cell.textLabel.text = [NSString stringWithFormat:@"%lu Notice%@", (unsigned long)_venueNotices.count, _venueNotices.count == 1 ? @"" : @"s"];
                    
                }
                    break;
                    
                case 4: {
                    UILabel *ratingLabel = (UILabel*)[cell viewWithTag:1];
                    ratingLabel.text = [NSString stringWithFormat:@"%.1f", self.opportunity.effortRating.doubleValue];
                    
                    XASRateView *rateView = (XASRateView*)[cell viewWithTag:2];
                    rateView.editable = NO;
                    rateView.backgroundColor = [UIColor clearColor];
                    rateView.rate = self.opportunity.effortRating.doubleValue;
                    rateView.starImage = [UIImage imageNamed:@"sweat-blue"];
                    
                }
                    break;
                    
                case 5: {
                    UITextView *textView = (UITextView*)[cell viewWithTag:1];
                    NSAttributedString *description = [self buildAttributedString:self.opportunity.opportunityDescription];
                    
                    textView.selectable = YES;
                    textView.attributedText = description;
                    [textView sizeToFit];
                    [textView layoutIfNeeded];
                    textView.scrollEnabled = NO;
                }
                    break;
                    
                case 6: {
                    UILabel *tagsLabel = (UILabel*)[cell viewWithTag:1];
                    
                    tagsLabel.text = [[self.opportunity.tagsArray valueForKey:@"description"] componentsJoinedByString:@", "];
                    if([tagsLabel.text isEqualToString:@""]) {
                        tagsLabel.text = @"No tags set";
                    }
                }
                    break;
                
                    
                case 7: {
                    UILabel *addressLabel = (UILabel*)[cell viewWithTag:1];
                    UILabel *telephoneLabel = (UILabel*)[cell viewWithTag:2];
                    UILabel *webLabel = (UILabel*)[cell viewWithTag:3];
                    
                    addressLabel.text = [NSString stringWithFormat:@"%@, %@",
                                         self.opportunity.venue.address,
                                         self.opportunity.venue.postCode];
                    
                    telephoneLabel.text = self.opportunity.venue.phone;
                    webLabel.text = self.opportunity.venue.website;
                }
                    break;
                    
                case 8: {
                    
                    MKMapView *mapView = (MKMapView*)[cell viewWithTag:1];
                    
                    mapView.delegate = self;
                    
                    
                    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                    point.coordinate = CLLocationCoordinate2DMake(self.opportunity.venue.locationLat.doubleValue, self.opportunity.venue.locationLong.doubleValue);
                    point.title = self.opportunity.name;
                    
                    [mapView addAnnotation:point];
                    
                    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
                    
                    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.opportunity.venue.locationLat.doubleValue, self.opportunity.venue.locationLong.doubleValue);
                    
                    [mapView setRegion:[mapView regionThatFits:MKCoordinateRegionMake(center, span)] animated:NO];
                    
                }
                    break;
                    
                    
                default:
                    break;
            }
        }
            break;
            
        case 1: {
            static NSDateFormatter *dateFormatter = nil;
            if (dateFormatter == nil) {
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                [dateFormatter setLocale:[NSLocale currentLocale]];
            }
            
            XASVenueNotice *venueNotice = [_venueNotices objectAtIndex:indexPath.row];
            
            UILabel *startsLabel = (UILabel*)[cell viewWithTag:1];
            UITextView *textView = (UITextView*)[cell viewWithTag:2];
            
            startsLabel.text = [dateFormatter stringFromDate:venueNotice.starts];
            
            NSAttributedString *description = [self buildAttributedString:venueNotice.message];
            
            textView.attributedText = description;
            [textView sizeToFit];
            [textView layoutIfNeeded];
            textView.scrollEnabled = NO;

            
        }
            break;
    }
    
    // Configure the cell...
    
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
    if ([[segue identifier] isEqualToString:@"rate"]) {
        
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        
        XASRateViewController *controller = (XASRateViewController*)[segue destinationViewController];
    
        controller.opportunity = self.opportunity;
    }
}

#pragma mark - Preferences
- (NSString*)preferencesFilepath {
    
    NSString *documentsDir = [XASBaseObject cacheDirectory];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"favourites"]];
    
    return path;
}


@end
