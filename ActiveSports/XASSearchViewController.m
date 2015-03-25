//
//  XASSearchViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 21/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASSearchViewController.h"
#import "XASRateView.h"
#import "XASOpportunitiesTableViewController.h"
#import "UIImage+Resize.h"
#import "Constants.h"
#import "UIColor+Expanded.h"
#import "XASRangeSlider.h"

@interface XASSearchViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *dayQuickSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *daySegmentedControl;

@property (weak, nonatomic) IBOutlet UISegmentedControl *timeOfDaySegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITextField *textSearchField;
@property (weak, nonatomic) IBOutlet XASRangeSlider *rangeSlider;

@end



@implementation XASSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.rangeSlider.trackColour = [UIColor colorWithWhite:0.5 alpha:1.0];
    self.rangeSlider.trackHighlightColour = [UIColor colorWithHexString:XASNegativeActionColor];
    self.rangeSlider.knobColour = [UIColor colorWithHexString:XASBrandMainColor];
    self.rangeSlider.backgroundColor = [UIColor clearColor];
    self.dayQuickSegmentedControl.tintColor = [UIColor colorWithHexString:XASBrandMainColor];
    self.daySegmentedControl.tintColor = [UIColor colorWithHexString:XASBrandMainColor];
    self.timeOfDaySegmentedControl.tintColor = [UIColor colorWithHexString:XASBrandMainColor];
    self.searchButton.backgroundColor = [UIColor colorWithHexString:XASPositveActionColor];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:XASBrandMainColor];
    
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:NSCalendarUnitWeekday fromDate:today];
    NSInteger weekday = [weekdayComponents weekday] - 1;
    [self.daySegmentedControl setSelectedSegmentIndex:weekday];
    
    // Style the segment controls
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:XASFontRegular size:13], NSFontAttributeName,
                                nil];
    [self.dayQuickSegmentedControl setTitleTextAttributes:attributes
                                                 forState:UIControlStateNormal];
    
    [self.daySegmentedControl setTitleTextAttributes:attributes
                                            forState:UIControlStateNormal];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.delegate = self;
    
    
    self.searchButton.layer.cornerRadius = 2.0f;
    
    [self.searchButton setBackgroundColor:[UIColor colorWithHexString:XASPositveActionColor]];
    [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:XASBrandMainColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /*
     self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.090 green:0.161 blue:0.490 alpha:1], NSForegroundColorAttributeName, nil];
     */
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)dayQuickChanged:(UISegmentedControl *)sender {
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:NSCalendarUnitWeekday fromDate:today];
    NSInteger weekday = [weekdayComponents weekday] - 1;
    
    switch (sender.selectedSegmentIndex) {
        case 0: // Today
            [self.daySegmentedControl setSelectedSegmentIndex:weekday];
            break;
            
        case 1: // Tomorrow
            [self.daySegmentedControl setSelectedSegmentIndex:(weekday + 1) % 7];
            break;
            
        default:
            break;
    }
}

- (IBAction)slideValueChanged:(id)sender {
    
    XASRangeSlider *slider = (XASRangeSlider*)sender;
    
    int minValue = (int)slider.lowerValue;
    int maxValue = (int)slider.upperValue;
    
    for(int tag = 1; tag < 6; tag++) {
        UIImageView *imageView = (UIImageView*)[slider.superview viewWithTag:tag];
        
        if(tag < minValue || tag > maxValue) {
            imageView.image = [UIImage imageNamed:@"drop-rating-small-grey"];
        } else {
            imageView.image = [UIImage imageNamed:@"drop-rating-small"];
        }
    }
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.0;
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}
 */

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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"search"]) {
        
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        
        XASOpportunitiesTableViewController *controller = (XASOpportunitiesTableViewController*)[segue destinationViewController];
        
        NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];
        [searchDictionary setObject:[NSNumber numberWithInteger:self.daySegmentedControl.selectedSegmentIndex] forKey:@"dayOfWeek"];
        [searchDictionary setObject:[NSNumber numberWithInteger:self.timeOfDaySegmentedControl.selectedSegmentIndex] forKey:@"timeOfDay"];
        [searchDictionary setObject:[NSNumber numberWithInteger:round(self.rangeSlider.lowerValue)] forKey:@"minimumExertion"];
        [searchDictionary setObject:[NSNumber numberWithInteger:round(self.rangeSlider.upperValue)] forKey:@"maximumExertion"];
        [searchDictionary setObject:self.textSearchField.text forKey:@"text"];
        
        controller.viewType = XASOpportunitiesViewSearch;
        controller.searchDictionary = [NSDictionary dictionaryWithDictionary:searchDictionary];
    }

}

@end
