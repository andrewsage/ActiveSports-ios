//
//  XASHomeViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 25/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASHomeViewController.h"
#import "XASOpportunitiesTableViewController.h"



@interface XASHomeViewController ()


@end

@implementation XASHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.view.backgroundColor = [UIColor colorWithRed:0.090 green:0.161 blue:0.490 alpha:1];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

    [super viewWillAppear:animated];
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
