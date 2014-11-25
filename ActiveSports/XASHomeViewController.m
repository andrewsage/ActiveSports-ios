//
//  XASHomeViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 25/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASHomeViewController.h"
#import "SWRevealViewController.h"
#import "XASOpportunitiesTableViewController.h"



@interface XASHomeViewController ()


@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;

@end

@implementation XASHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        // Change button color
        //self.revealButtonItem.tintColor = [UIColor colorWithWhite:0.96f alpha:0.2f];
        
        // Set the gesture
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( rightRevealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"likes"]) {
        XASOpportunitiesTableViewController *opportunitiesController = (XASOpportunitiesTableViewController*)segue.destinationViewController;
        opportunitiesController.viewType = XASOpportunitiesViewLikes;
        
    }
}

@end
