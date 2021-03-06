//
//  XASProfileTableViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 26/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASProfileTableViewController.h"
#import "XASActivity.h"
#import "XASPreferenceTableViewCell.h"
#import "UIColor+Expanded.h"
#import "Constants.h"
#import "XASHeaderView.h"


@interface XASProfileTableViewController () <UIActionSheetDelegate> {
    NSMutableArray *_objectsArray;
    NSMutableDictionary *_preferencesDictionary;
}

@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet XASHeaderView *headerView;

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
    
    self.answerButton.hidden = (_preferencesDictionary.count == _objectsArray.count);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Your preferences";
        
    self.answerButton.layer.cornerRadius = 2.0f;
    [self.answerButton setBackgroundColor:[UIColor colorWithHexString:XASBrandMainColor]];
    [self.answerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.answerButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.answerButton sizeToFit];
    
    self.resetButton.layer.cornerRadius = 2.0f;
    [self.resetButton setBackgroundColor:[UIColor colorWithHexString:XASNegativeActionColor]];
    [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resetButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.resetButton sizeToFit];
    
    /*
    [XASActivity fetchAllInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if(error) {
            NSLog(@"Error downloading activitiy list %@", error);
        } else {
            [self dataLoaded];
        }
    }];

     */
    
    [self dataLoaded];
}


- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:XASBrandMainColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:XASBrandMainColor], NSForegroundColorAttributeName, nil];

    [super viewWillAppear:animated];
    
    _preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(_preferencesDictionary == nil) {
        _preferencesDictionary = [NSMutableDictionary dictionary];
    }
    
    self.answerButton.hidden = (_preferencesDictionary.count == _objectsArray.count);

    
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
    XASPreferenceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activity" forIndexPath:indexPath];
    
    XASActivity *activity = [_objectsArray objectAtIndex:indexPath.row];
    /*
    if([_preferencesDictionary objectForKey:activity.remoteID] == nil) {
        cell.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.929 alpha:1];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
     */
    
    NSNumber *included = [_preferencesDictionary objectForKey:activity.remoteID];
    // Configure the cell...
    cell.titleLabel.text = activity.title;
    if(included.boolValue) {
        cell.yesImageView.alpha = 1.0f;
        cell.noImageView.alpha = 0.25f;
    } else {
        cell.yesImageView.alpha = 0.25f;
        cell.noImageView.alpha = 1.0f;
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
    self.answerButton.hidden = (_preferencesDictionary.count == _objectsArray.count);

}


#pragma mark - Actions
- (IBAction)homeTapped:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)resetTapped:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Are you sure you wish to reset your preferences?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Reset"
                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 0) {
        // Reset
        
        [_preferencesDictionary removeAllObjects];
        
        if([NSKeyedArchiver archiveRootObject:_preferencesDictionary toFile:[self preferencesFilepath]]) {
        } else {
            NSLog(@"Failed to save dictionary");
        }
        [self.tableView reloadData];
        self.answerButton.hidden = (_preferencesDictionary.count == _objectsArray.count);

        
    } else if(buttonIndex == 1) {
        // do your other action
    }
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
