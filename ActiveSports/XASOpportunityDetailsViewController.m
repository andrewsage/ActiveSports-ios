//
//  XASOpportunityDetailsViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 19/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASOpportunityDetailsViewController.h"

@interface XASOpportunityDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation XASOpportunityDetailsViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleLabel.text = self.opportunity.name;
    self.dayTimeLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",
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

    [description appendAttributedString:[[NSAttributedString alloc] initWithString:self.opportunity.venue.name
                                         attributes:boldTextAttributes]];
    
    
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:self.opportunity.venue.address attributes:bodyTextAttributes]];
    
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];

    [description appendAttributedString:[[NSAttributedString alloc] initWithString:self.opportunity.venue.postCode attributes:bodyTextAttributes]];
    
    self.descriptionTextView.attributedText = description;
    
    

    
    
    
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
    
    
    // Hide the sweat drops if required
    for(NSInteger loop = 1; loop < 6; loop++) {
        UIView *view = [self.view viewWithTag:loop];
        view.alpha = loop > self.opportunity.effortRating.integerValue ? 0.4 : 1.0;
    }
    
    
    [self.mapView addAnnotation:point];
    
    [self zoomToVenue];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)zoomToVenue {
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.opportunity.venue.locationLat.doubleValue, self.opportunity.venue.locationLong.doubleValue);
    
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake(center, span)] animated:YES];
}

@end
