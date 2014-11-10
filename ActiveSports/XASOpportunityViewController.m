//
//  XASOpportunityViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 01/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASOpportunityViewController.h"
#import "XASRateViewController.h"

@interface XASOpportunityViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *opportunityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *whenLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
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

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

    
    self.opportunityNameLabel.text = self.opportunity.name;
    self.whenLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",
                           self.opportunity.dayOfWeek,
                           self.opportunity.startTime,
                           self.opportunity.endTime];
    self.venueLabel.text = self.opportunity.venue.name;
    
    UIFont *boldFont = [UIFont fontWithName:@"Arial-BoldMT"
                                       size:14];
    
    UIFont *bodyFont = [UIFont fontWithName:@"ArialMT"
                                       size:14];
    
    NSDictionary *boldTextAttributes = @{NSFontAttributeName : boldFont};
    NSDictionary *bodyTextAttributes = @{NSFontAttributeName : bodyFont};
    
    
    NSMutableAttributedString *descriptionText = [[NSMutableAttributedString alloc] initWithData:[self.opportunity.opportunityDescription dataUsingEncoding:NSUTF8StringEncoding]
                                                                                         options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                   NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                                              documentAttributes:nil error:nil];
    
    [descriptionText setAttributes:bodyTextAttributes range:NSMakeRange(0, descriptionText.length)];
    
    
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithString:@""];
    
    [description appendAttributedString:descriptionText];
    
    
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    /*
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:self.opportunity.venue.name
                                                                        attributes:boldTextAttributes]];
    
    
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:self.opportunity.venue.address attributes:bodyTextAttributes]];
    
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:self.opportunity.venue.postCode attributes:bodyTextAttributes]];
    */
    
    self.descriptionTextView.attributedText = description;
    [self.descriptionTextView sizeToFit];
    [self.descriptionTextView layoutIfNeeded];
    self.descriptionTextView.scrollEnabled = NO;
    
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@",
                              self.opportunity.venue.address,
                              self.opportunity.venue.postCode];
    
    self.title = self.opportunity.name;

    
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
            self.imageView.image = [UIImage imageWithContentsOfFile:cachedImageURL.absoluteString];
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
                                
                                self.imageView.image = image;
                                
                            });
                            
                        }
                        
                    }] resume];
        }
    }

    
    self.mapView.delegate = self;
    
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(self.opportunity.venue.locationLat.doubleValue, self.opportunity.venue.locationLong.doubleValue);
    point.title = self.opportunity.name;
    
    
    NSArray *effortIconViews = @[self.effortIconView1, self.effortIconView2, self.effortIconView3, self.effortIconView4, self.effortIconView5];
    // Hide the sweat drops if required
    for(NSInteger loop = 0; loop < 5; loop++) {
        UIView *effortIconView = effortIconViews[loop];
        effortIconView.alpha = loop + 1 > self.opportunity.effortRating.integerValue ? 0.4 : 1.0;
    }
    
    self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", self.opportunity.effortRating.doubleValue];
    
    
    if([self.opportunity.imageURL isKindOfClass:[NSNull class]]) {
        self.imageHeightConstraint.constant = 0.0f;
    }

    
    [self.mapView addAnnotation:point];
    
    [self zoomToVenue];

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44.0f;
    
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
            CGSize size = [self.descriptionTextView sizeThatFits:CGSizeMake(tableView.frame.size.width, FLT_MAX)];
            height = size.height;
        }
            break;
            
        case 3: // Address
            height = 70.0f;
            break;
            
        case 4: // map
            height = 150.0f;
            break;
            
        default:
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

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
