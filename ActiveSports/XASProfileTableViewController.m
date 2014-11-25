//
//  XASProfileTableViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 26/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASProfileTableViewController.h"
#import "SWRevealViewController.h"
#import "XASActivity.h"


@interface XASProfileTableViewController () {
    NSMutableArray *_objectsArray;
    NSDictionary *_preferencesDictionary;
}

@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;

@end

@implementation XASProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: revealViewController];
        [self.revealButtonItem setAction: @selector( rightRevealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }

    _objectsArray = [NSMutableArray arrayWithCapacity:0];
    _preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(_preferencesDictionary == nil) {
        _preferencesDictionary = [NSDictionary dictionary];
    }
    
    if([XASActivity dictionary].allKeys.count == 0) {
        
        [XASActivity fetchAllInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if(error) {
                NSLog(@"error: %@", error.localizedDescription);
            } else {
                [self buildArray];
            }
        }];
    } else {
        [self buildArray];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    _preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(_preferencesDictionary == nil) {
        _preferencesDictionary = [NSDictionary dictionary];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildArray {
    
    NSDictionary *activitiesDictionary = [XASActivity dictionary];
    for(NSString *key in activitiesDictionary.allKeys) {
        XASActivity *activity = [activitiesDictionary objectForKey:key];
        [_objectsArray addObject:activity];
    }
    
    [_objectsArray sortUsingComparator:^(XASActivity *activity1,
                                         XASActivity *activity2){
        
        return [activity1.title compare:activity2.title options:NSCaseInsensitiveSearch];
    }];
    
    [self.tableView reloadData];
    
    if(_preferencesDictionary.count != _objectsArray.count) {
        [self performSegueWithIdentifier:@"build" sender:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objectsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activity" forIndexPath:indexPath];
    
    XASActivity *activity = [_objectsArray objectAtIndex:indexPath.row];
    NSNumber *included = [_preferencesDictionary objectForKey:activity.remoteID];
    // Configure the cell...
    cell.textLabel.text = activity.title;
    if(included.boolValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Preferences
- (NSString*)preferencesFilepath {
    
    NSString *documentsDir = [XASBaseObject cacheDirectory];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"profile"]];
    
    return path;
}

@end
