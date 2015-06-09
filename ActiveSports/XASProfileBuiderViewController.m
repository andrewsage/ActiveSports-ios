//
//  XASProfileBuiderViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 17/11/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASProfileBuiderViewController.h"
#import "XASActivity.h"
#import "XASProgressView.h"


@interface XASProfileBuiderViewController () {
    NSInteger _currentActivityIndex;
    NSMutableArray *_activitiesArray;
    NSMutableDictionary *_preferencesDictionary;

}
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet XASProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIView *detailsBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@end

@implementation XASProfileBuiderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.skipButton.layer.cornerRadius = 5.0f;
    self.skipButton.layer.masksToBounds = YES;
    self.detailsBackgroundView.layer.cornerRadius = 5.0f;
    self.detailsBackgroundView.layer.masksToBounds = YES;
    
    [self.skipButton setTitleColor:[UIColor colorWithRed:0.110 green:0.090 blue:0.541 alpha:1] forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.110 green:0.090 blue:0.541 alpha:1];
    
    _preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(_preferencesDictionary == nil) {
        _preferencesDictionary = [NSMutableDictionary dictionary];
    }
    
    _currentActivityIndex = 0;
    _activitiesArray = [NSMutableArray arrayWithCapacity:0];
    
    [self buildArray];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)buildArray {
    NSDictionary *dictionary = [XASActivity dictionary];
    for(NSString *key in dictionary.allKeys) {
        XASActivity *activity = [dictionary objectForKey:key];
        
        [_activitiesArray addObject:activity];
    }
    [self displayDetails];
}

- (void)displayDetails {
    if(_activitiesArray.count > 0) {
        XASActivity *activity = [_activitiesArray objectAtIndex:_currentActivityIndex];
        
        if(activity) {
            if([_preferencesDictionary objectForKey:activity.remoteID]) {
                [self nextActivity];
            } else {
                NSInteger progress = (_currentActivityIndex * 100) / _activitiesArray.count;
                self.activityLabel.text = [NSString stringWithFormat:@"%@?", activity.title];
                self.progressLabel.text = [NSString stringWithFormat:@"%ld%% complete",
                                           (long)progress];
                self.progressView.percentage = progress;
            }
        }
    } else {
        self.yesButton.hidden = YES;
        self.noButton.hidden = YES;
        self.activityLabel.text = @"No activity data has been downloaded";
        self.progressLabel.text = @"0% complete";
        self.progressView.percentage = 0.0;
    }
}

#pragma mark - Actions

- (void)nextActivity {
    if(_currentActivityIndex + 1 < _activitiesArray.count) {
        _currentActivityIndex++;
        [self displayDetails];
    } else {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
}

- (IBAction)noTapped:(id)sender {
    
    XASActivity *activity = [_activitiesArray objectAtIndex:_currentActivityIndex];

    [_preferencesDictionary setObject:[NSNumber numberWithBool:NO] forKey:activity.remoteID];
    
    if([NSKeyedArchiver archiveRootObject:_preferencesDictionary toFile:[self preferencesFilepath]]) {
    } else {
        NSLog(@"Failed to save dictionary");
    }

    [self nextActivity];
}

- (IBAction)yesTapped:(id)sender {
    
    XASActivity *activity = [_activitiesArray objectAtIndex:_currentActivityIndex];
    [_preferencesDictionary setObject:[NSNumber numberWithBool:YES] forKey:activity.remoteID];
    if([NSKeyedArchiver archiveRootObject:_preferencesDictionary toFile:[self preferencesFilepath]]) {
    } else {
        NSLog(@"Failed to save dictionary");
    }
    [self nextActivity];
}

- (IBAction)skipTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Preferences
- (NSString*)preferencesFilepath {
    
    
    NSString *documentsDir = [XASBaseObject cacheDirectory];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"profile"]];
    
    return path;
}


@end
