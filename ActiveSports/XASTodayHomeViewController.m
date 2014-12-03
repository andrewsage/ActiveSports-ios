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
@property (weak, nonatomic) IBOutlet UIButton *strengthButton;
@property (weak, nonatomic) IBOutlet UIButton *cardioButton;
@property (weak, nonatomic) IBOutlet UIButton *weightLossButton;
@property (weak, nonatomic) IBOutlet UIButton *flexibilityButton;
@property (weak, nonatomic) IBOutlet UIButton *resultsButton;

@end

@implementation XASTodayHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.strengthButton.layer.borderWidth = 1.0f;
    self.strengthButton.layer.cornerRadius = 2.0f;
    self.strengthButton.layer.borderColor = [UIColor blueColor].CGColor;

    self.cardioButton.layer.borderWidth = 1.0f;
    self.cardioButton.layer.cornerRadius = 2.0f;
    self.cardioButton.layer.borderColor = [UIColor blueColor].CGColor;
    
    self.weightLossButton.layer.borderWidth = 1.0f;
    self.weightLossButton.layer.cornerRadius = 2.0f;
    self.weightLossButton.layer.borderColor = [UIColor blueColor].CGColor;
    
    self.flexibilityButton.layer.borderWidth = 1.0f;
    self.flexibilityButton.layer.cornerRadius = 2.0f;
    self.flexibilityButton.layer.borderColor = [UIColor blueColor].CGColor;
    
    self.resultsButton.layer.cornerRadius = 2.0f;
    
    [self.resultsButton setBackgroundColor:[UIColor colorWithRed:0.169 green:0.655 blue:0.098 alpha:1]];
    [self.resultsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.title = @"Activties near you";
}


- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.090 green:0.161 blue:0.490 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.090 green:0.161 blue:0.490 alpha:1], NSForegroundColorAttributeName, nil];
    
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
    
    if([segue.identifier isEqualToString:@"results"]) {
        XASOpportunitiesTableViewController *controller = (XASOpportunitiesTableViewController*)[segue destinationViewController];
        
        NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];
        NSMutableArray *tagsArray = [NSMutableArray arrayWithCapacity:0];
        
        if(self.strengthButton.selected) {
            [tagsArray addObject:@"strength"];
        }
        if(self.cardioButton.selected) {
            [tagsArray addObject:@"cardio"];
        }
        if(self.weightLossButton.selected) {
            [tagsArray addObject:@"weight loss"];
        }
        if(self.flexibilityButton.selected) {
            [tagsArray addObject:@"flexibility"];
        }
        [searchDictionary setObject:tagsArray forKey:@"tag"];
        
        controller.viewType = XASOpportunitiesViewSearch;
        controller.searchDictionary = [NSDictionary dictionaryWithDictionary:searchDictionary];
    }
}

#pragma mark - Actions

- (IBAction)buttonPressed:(UIButton *)sender {
    if([sender isSelected]) {
        [sender setSelected:NO];
        sender.backgroundColor = [UIColor whiteColor];
    } else {
        [sender setSelected:YES];
        sender.backgroundColor = [UIColor blueColor];
    }
}


@end
