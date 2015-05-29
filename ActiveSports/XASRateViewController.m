//
//  XASRateViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 07/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASRateViewController.h"
#import "XASRateView.h"
#import "UIImage+Resize.h"

@interface XASRateViewController () <XASRateViewDelegate>
@property (weak, nonatomic) IBOutlet XASRateView *rateView;
@property (weak, nonatomic) IBOutlet XASRateView *currentRatingView;

@end

@implementation XASRateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = [NSString stringWithFormat:@"Rate %@", self.opportunity.name];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.914 green:0.204 blue:0.220 alpha:1];
    
    self.opportunityNameLabel.text = [NSString stringWithFormat:@"%@?", self.opportunity.name];

    self.currentRatingView.rate = self.opportunity.effortRating.integerValue;
    self.currentRatingView.starImage = [UIImage imageWithImage:[UIImage imageNamed:@"drop-rating-big"] scaledToSize:CGSizeMake(34.0 / 2.0, 45.0 / 2.0)];
    
    self.currentRatingView.padding = 10;
    self.currentRatingView.alignment = XASRateViewAlignmentCenter;
    self.currentRatingView.editable = NO;
    self.currentRatingView.delegate = self;

    self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", self.opportunity.effortRating.doubleValue];
    
    self.rateView.starImage = [UIImage imageWithImage:[UIImage imageNamed:@"drop-rating-small"] scaledToSize:CGSizeMake(71.0 / 2.0, 94.0 / 2.0)];

    self.rateView.padding = 10;
    self.rateView.alignment = XASRateViewAlignmentCenter;
    self.rateView.editable = YES;
    self.rateView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - XASRateViewDelegate

- (void)rateView:(XASRateView *)rateView changedToNewRate:(NSNumber *)rate {
    NSLog(@"%@", [NSString stringWithFormat:@"Rate: %d", rate.intValue]);
    
    [self.opportunity rateInBackground:rate.intValue
                             withBlock:^(BOOL succeeded, NSError *error) {
                                 if(error) {
                                     UIAlertController *alertController = [UIAlertController
                                                                           alertControllerWithTitle:@"Rating Error"
                                                                           message:[NSString stringWithFormat:@"There was a problem sending your rating: %@", error.localizedDescription]
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                     
                                     UIAlertAction *okAction = [UIAlertAction
                                                                actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                                style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                }];
                                     
                                     [alertController addAction:okAction];
                                     
                                     [self presentViewController:alertController
                                                        animated:YES
                                                      completion:^{
                                                          
                                                      }];
                                 }
                                 
                                 [self.navigationController popViewControllerAnimated:YES];
                             }];
}

@end
