//
//  XASCollectionsTableViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASCollectionsTableViewController.h"
#import "XASRegion.h"
#import "XASVenue.h"
#import "XASOpportunity.h"
#import "XASCollectionTableViewController.h"

@interface XASCollectionsTableViewController () {
    NSDictionary *_collectionNamesDictionary;
    NSMutableDictionary *_collectionsDictionary;
}

@end

@implementation XASCollectionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    
    _collectionNamesDictionary = @{
                               @"Regions" : [XASRegion class],
                               @"Venues" : [XASVenue class],
                               @"Opportunities" : [XASOpportunity class]
                               };
    
    _collectionsDictionary = [@{
                               @"Regions" : [NSArray array],
                               @"Venues" : [NSArray array],
                               @"Opportunities" : [NSArray array]
                               } mutableCopy];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self refreshContent];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.996 green:0.816 blue:0.216 alpha:1];

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

    return _collectionNamesDictionary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collection" forIndexPath:indexPath];
    
    NSString *key = [_collectionNamesDictionary.allKeys objectAtIndex:indexPath.row];
    // Configure the cell...
    cell.textLabel.text = key;
    
    NSArray *collectionArray = [_collectionsDictionary objectForKey:key];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)collectionArray.count];
    
    
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"show"]) {
    
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *key = [_collectionNamesDictionary.allKeys objectAtIndex:indexPath.row];
        
        
        XASCollectionTableViewController *controller = (XASCollectionTableViewController*)segue.destinationViewController;
        controller.collectionArray = [_collectionsDictionary objectForKey:key];
    }
}

- (void)refreshTable {
    [self refreshContent];
    [self.refreshControl endRefreshing];
}

#pragma mark - Data

- (void)refreshContent {
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    for(NSString *key in _collectionNamesDictionary.allKeys) {
        id collectionClass = [_collectionNamesDictionary objectForKey:key];
        
        [collectionClass fetchAllInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            
            if(error) {
                NSLog(@"Error %@: %@", key, error.localizedDescription);
            } else {
                [_collectionsDictionary setObject:array forKey:key];
                [self.tableView reloadData];
            }
        }];
    }
}

@end
