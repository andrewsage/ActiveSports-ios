//
//  XASRateViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 07/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASRateViewController.h"
#import "XASRateView.h"

@interface XASRateViewController () <XASRateViewDelegate>
@property (weak, nonatomic) IBOutlet XASRateView *rateView;

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
    
    self.opportunityNameLabel.text = self.opportunity.name;

    
    NSArray *effortIconViews = @[self.effortIconView1, self.effortIconView2, self.effortIconView3, self.effortIconView4, self.effortIconView5];
    // Hide the sweat drops if required
    for(NSInteger loop = 0; loop < 5; loop++) {
        UIView *effortIconView = effortIconViews[loop];
        effortIconView.alpha = loop + 1 > self.opportunity.effortRating.integerValue ? 0.4 : 1.0;
    }
    
    self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", self.opportunity.effortRating.doubleValue];
    
    self.rateView.starImage = [UIImage imageNamed:@"drop-rating-small"];

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
                                     NSLog(@"Error rating: %@", error.localizedDescription);
                                 }
                                 
                                 [self.navigationController popViewControllerAnimated:YES];
                             }];
}

@end
