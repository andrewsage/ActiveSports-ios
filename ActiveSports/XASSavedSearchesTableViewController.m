//
//  XASSavedSearchesTableViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 02/03/2015.
//  Copyright (c) 2015 Xoverto. All rights reserved.
//

#import "XASSavedSearchesTableViewController.h"
#import "Constants.h"
#import "UIColor+Expanded.h"
#import "XASOpportunitiesTableViewController.h"

@interface XASSavedSearchesTableViewController () {
    
    NSMutableDictionary *_savedSearchesDictionary;
    NSMutableArray *_savesSearchesArray;

}

@end

@implementation XASSavedSearchesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Saved Searches";
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *searchQueriesPath = [documentDirectory stringByAppendingPathExtension:@"searches"];
    
    
    _savedSearchesDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:searchQueriesPath];
    
    if(_savedSearchesDictionary == nil) {
        _savedSearchesDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    [_savedSearchesDictionary writeToFile:searchQueriesPath atomically:YES];
    
    _savesSearchesArray = [NSMutableArray arrayWithArray:_savedSearchesDictionary.allKeys];
    [_savesSearchesArray sortUsingComparator:^(NSString *title1,
                                        NSString *title2){
        
        return [title1 compare:title2 options:NSCaseInsensitiveSearch];
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:XASBrandMainColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:XASBrandMainColor], NSForegroundColorAttributeName, nil];
    
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

- (IBAction)homePressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _savesSearchesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"search" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSString *searchName = [_savesSearchesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = searchName;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *searchName = [_savesSearchesArray objectAtIndex:indexPath.row];

        [_savedSearchesDictionary removeObjectForKey:searchName];
        [_savesSearchesArray removeObjectAtIndex:indexPath.row];
        
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *searchQueriesPath = [documentDirectory stringByAppendingPathExtension:@"searches"];
        
        
        [_savedSearchesDictionary writeToFile:searchQueriesPath atomically:YES];
        
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
        
        NSIndexPath *currentSelection = [self.tableView indexPathForSelectedRow];

        
        NSString *searchDictionaryKey = [_savesSearchesArray objectAtIndex:currentSelection.row];
    
        controller.viewType = XASOpportunitiesViewSavedSearch;
        controller.searchDictionary = [NSDictionary dictionaryWithDictionary:[_savedSearchesDictionary objectForKey:searchDictionaryKey]];
        controller.searchName = searchDictionaryKey;
    }

}

@end
