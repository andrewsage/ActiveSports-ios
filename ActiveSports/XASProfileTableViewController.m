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
    NSMutableDictionary *_preferencesDictionary;
}

@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;

@end

@implementation XASProfileTableViewController

- (void)dataLoaded {
    _objectsArray = [NSMutableArray arrayWithCapacity:0];
    _preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(_preferencesDictionary == nil) {
        _preferencesDictionary = [NSMutableDictionary dictionary];
    }
    NSDictionary *activitiesDictionary = [XASActivity dictionary];
    for(NSString *key in activitiesDictionary.allKeys) {
        XASActivity *activity = [activitiesDictionary objectForKey:key];
        [_objectsArray addObject:activity];
    }
    
    [_objectsArray sortUsingComparator:^(XASActivity *activity1,
                                         XASActivity *activity2){
        
        return [activity1.title compare:activity2.title options:NSCaseInsensitiveSearch];
    }];
    
    if(_preferencesDictionary.count != _objectsArray.count) {
        [self performSegueWithIdentifier:@"build" sender:self];
    }
}

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
    
    [XASActivity fetchAllInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if(error) {
            NSLog(@"Error downloading activitiy list %@", error);
        } else {
            [self dataLoaded];
        }
    }];

    [self dataLoaded];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    _preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(_preferencesDictionary == nil) {
        _preferencesDictionary = [NSMutableDictionary dictionary];
    }
    
    [self.tableView reloadData];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XASActivity *activity = [_objectsArray objectAtIndex:indexPath.row];
    NSNumber *included = [_preferencesDictionary objectForKey:activity.remoteID];
    if(included.boolValue) {
        [_preferencesDictionary setObject:[NSNumber numberWithBool:NO] forKey:activity.remoteID];
    } else {
        [_preferencesDictionary setObject:[NSNumber numberWithBool:YES] forKey:activity.remoteID];
    }
    
    if([NSKeyedArchiver archiveRootObject:_preferencesDictionary toFile:[self preferencesFilepath]]) {
    } else {
        NSLog(@"Failed to save dictionary");
    }
    [self.tableView reloadData];
}

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
