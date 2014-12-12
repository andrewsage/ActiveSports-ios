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

@interface XASOpportunityViewController () {
    NSMutableArray *_venueNotices;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *effortIconView1;
@property (weak, nonatomic) IBOutlet UIImageView *effortIconView2;
@property (weak, nonatomic) IBOutlet UIImageView *effortIconView3;
@property (weak, nonatomic) IBOutlet UIImageView *effortIconView4;
@property (weak, nonatomic) IBOutlet UIImageView *effortIconView5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *telephoneLabel;

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
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.090 green:0.161 blue:0.490 alpha:1];
    /*
    NSArray *effortIconViews = @[self.effortIconView1, self.effortIconView2, self.effortIconView3, self.effortIconView4, self.effortIconView5];
    // Hide the sweat drops if required
    for(NSInteger loop = 0; loop < 5; loop++) {
        UIView *effortIconView = effortIconViews[loop];
        effortIconView.alpha = loop + 1 > self.opportunity.effortRating.integerValue ? 0.4 : 1.0;
    }
     */
    
    self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", self.opportunity.effortRating.doubleValue];
    
    
    if([self.opportunity.imageURL isKindOfClass:[NSNull class]]) {
        self.imageHeightConstraint.constant = 0.0f;
    }
    
    self.tagsLabel.text = [[self.opportunity.tagsArray valueForKey:@"description"] componentsJoinedByString:@", "];
    if([self.tagsLabel.text isEqualToString:@""]) {
        self.tagsLabel.text = @"No tags set";
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.opportunity.name;

    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@",
                              self.opportunity.venue.address,
                              self.opportunity.venue.postCode];
    
    self.mapView.delegate = self;
    
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(self.opportunity.venue.locationLat.doubleValue, self.opportunity.venue.locationLong.doubleValue);
    point.title = self.opportunity.name;
    
    /*
    NSArray *effortIconViews = @[self.effortIconView1, self.effortIconView2, self.effortIconView3, self.effortIconView4, self.effortIconView5];
    // Hide the sweat drops if required
    for(NSInteger loop = 0; loop < 5; loop++) {
        UIView *effortIconView = effortIconViews[loop];
        effortIconView.alpha = loop + 1 > self.opportunity.effortRating.integerValue ? 0.4 : 1.0;
    }
     */
    
    self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", self.opportunity.effortRating.doubleValue];
    
    
    if([self.opportunity.imageURL isKindOfClass:[NSNull class]]) {
        self.imageHeightConstraint.constant = 0.0f;
    }

    
    [self.mapView addAnnotation:point];
    
    [self zoomToVenue];
    
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

- (void)zoomToVenue {
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.opportunity.venue.locationLat.doubleValue, self.opportunity.venue.locationLong.doubleValue);
    
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake(center, span)] animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 6;
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
            return @"Notices";
            break;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44.0f;
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: // image
                    if([self.opportunity.imageURL isKindOfClass:[NSNull class]]) {
                        height = 100.0f;
                    } else {
                        height = 250.0f;
                    }
                    break;
                    
                case 2: // description
                {
                    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
                    
                    NSMutableAttributedString *description = [self buildAttributedString:self.opportunity.opportunityDescription];
                    
                    textView.attributedText = description;
                    
                    CGSize size = [textView sizeThatFits:CGSizeMake(tableView.frame.size.width, FLT_MAX)];
                    height = size.height;
                }
                    break;
                    
                case 3: // Tags
                    height = 44.0f;
                    break;
                    
                case 4: // Address
                    height = 70.0f;
                    break;
                    
                case 5: // map
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
            
            NSMutableAttributedString *description = [self buildAttributedString:venueNotice.message];
            
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

- (NSMutableAttributedString *)buildAttributedString:(NSString*)sourceString {
    NSMutableAttributedString *descriptionText = [[NSMutableAttributedString alloc] initWithData:[sourceString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                         options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                   NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                                              documentAttributes:nil error:nil];
    
    UIFont *boldFont = [UIFont fontWithName:@"Arial-BoldMT"
                                       size:14];
    
    UIFont *bodyFont = [UIFont fontWithName:@"ArialMT"
                                       size:14];
    
    NSDictionary *boldTextAttributes = @{NSFontAttributeName : boldFont};
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
                    identifier = @"cell1";
                    break;
                case 1:
                    identifier = @"cell2";
                    break;
                case 2:
                    identifier = @"cell3";
                    break;
                case 3:
                    identifier = @"cell4";
                    break;
                case 4:
                    identifier = @"cell5";
                    break;
                case 5:
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
                case 0: {
                    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
                    UILabel *opportunityNameLabel = (UILabel*)[cell viewWithTag:2];
                    UILabel *whenLabel = (UILabel*)[cell viewWithTag:3];
                    UILabel *venueLabel = (UILabel*)[cell viewWithTag:4];
                    
                    opportunityNameLabel.text = self.opportunity.name;
                    whenLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",
                                           self.opportunity.dayOfWeek,
                                           self.opportunity.startTime,
                                           self.opportunity.endTime];
                    venueLabel.text = self.opportunity.venue.name;
                    
                    NSURLSession *session = [NSURLSession sharedSession];
                    if([self.opportunity.imageURL isKindOfClass:[NSNull class]] == NO) {
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
                    UITextView *textView = (UITextView*)[cell viewWithTag:1];
                    
                    NSMutableAttributedString *description = [self buildAttributedString:self.opportunity.opportunityDescription];
                    
                    textView.selectable = YES;
                    textView.attributedText = description;
                    [textView sizeToFit];
                    [textView layoutIfNeeded];
                    textView.scrollEnabled = NO;
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
            
            NSMutableAttributedString *description = [self buildAttributedString:venueNotice.message];
            
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

@end
