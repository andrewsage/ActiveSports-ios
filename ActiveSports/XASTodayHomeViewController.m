//
//  XASTodayHomeViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 01/12/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASTodayHomeViewController.h"
#import "XASOpportunitiesTableViewController.h"


@interface XASTodayHomeViewController ()

@end

@implementation XASTodayHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    if([segue.identifier isEqualToString:@"strength"]) {
        XASOpportunitiesTableViewController *controller = (XASOpportunitiesTableViewController*)[segue destinationViewController];
        
        NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];
        [searchDictionary setObject:@"strength" forKey:@"tag"];
        
        controller.viewType = XASOpportunitiesViewSearch;
        controller.searchDictionary = [NSDictionary dictionaryWithDictionary:searchDictionary];
    }
    
    if([segue.identifier isEqualToString:@"cardio"]) {
        XASOpportunitiesTableViewController *controller = (XASOpportunitiesTableViewController*)[segue destinationViewController];
        
        NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];
        [searchDictionary setObject:@"cardio" forKey:@"tag"];
        
        controller.viewType = XASOpportunitiesViewSearch;
        controller.searchDictionary = [NSDictionary dictionaryWithDictionary:searchDictionary];
    }
    
    if([segue.identifier isEqualToString:@"weight loss"]) {
        XASOpportunitiesTableViewController *controller = (XASOpportunitiesTableViewController*)[segue destinationViewController];
        
        NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];
        [searchDictionary setObject:@"weight loss" forKey:@"tag"];
        
        controller.viewType = XASOpportunitiesViewSearch;
        controller.searchDictionary = [NSDictionary dictionaryWithDictionary:searchDictionary];
    }
    
    if([segue.identifier isEqualToString:@"flexibility"]) {
        XASOpportunitiesTableViewController *controller = (XASOpportunitiesTableViewController*)[segue destinationViewController];
        
        NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];
        [searchDictionary setObject:@"flexibility" forKey:@"tag"];
        
        controller.viewType = XASOpportunitiesViewSearch;
        controller.searchDictionary = [NSDictionary dictionaryWithDictionary:searchDictionary];
    }
}

@end
