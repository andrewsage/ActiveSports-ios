//
//  ViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "ViewController.h"
#import "XASRegion.h"
#import "XASVenue.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getRegionsTapped:(id)sender {
    
    
    [XASRegion fetchAllInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if(error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"%lu array entries", (unsigned long)array.count);
            for(XASRegion *region in array) {
                NSLog(@"Region %@ id %@", region.name, region.remoteID);
                NSLog(@"Created %@", region.createdAt);
                NSLog(@"Updated %@", region.updatedAt);
            }
        }
        
    }];
    
    
    [XASVenue fetchAllInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if(error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"%lu array entries", (unsigned long)array.count);
            for(XASVenue *venue in array) {
                NSLog(@"Venue %@ id %@", venue.name, venue.remoteID);
                
                NSLog(@"Created %@", venue.createdAt);
                NSLog(@"Updated %@", venue.updatedAt);
            }
        }
        
    }];

    
}

@end
