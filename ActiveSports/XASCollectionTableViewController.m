//
//  XASCollectionTableViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 06/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASCollectionTableViewController.h"
#import "XASBaseObject.h"
#import "XASRegion.h"

@interface XASCollectionTableViewController () {
    NSArray *sectionTitles;
    NSMutableDictionary *objectsPerLetterDictionary;
}

@end

@implementation XASCollectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *indexLetters = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    objectsPerLetterDictionary = [NSMutableDictionary dictionary];
    for(NSString *index in indexLetters) {
        NSMutableArray *objectsForLetter = [NSMutableArray array];
        for(XASBaseObject *object in self.collectionArray) {
            NSString *name;
            
            if([object respondsToSelector:@selector(name)]) {
                name = [object performSelector:@selector(name) withObject:nil];
                if([[name substringToIndex:1] isEqualToString:index]) {
                    [objectsForLetter addObject:object];
                }
            }
        }
        
        NSArray *sortedArray;
        sortedArray = [objectsForLetter sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *nameA;
            NSString *nameB;
            if([a respondsToSelector:@selector(name)]) {
                nameA = [a performSelector:@selector(name) withObject:nil];
            }
            if([b respondsToSelector:@selector(name)]) {
                nameB = [b performSelector:@selector(name) withObject:nil];
            }
            
            return [nameA compare:nameB];
        }];
        
        if(sortedArray.count > 0) {
            [objectsPerLetterDictionary setObject:sortedArray forKey:index];
        }
    }
    
    sectionTitles = [[objectsPerLetterDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return sectionTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *indexLetter = [sectionTitles objectAtIndex:section];
    NSArray *objectsForLetter = [objectsPerLetterDictionary objectForKey:indexLetter];
    
    return objectsForLetter.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"object" forIndexPath:indexPath];
    
    
    NSString *indexLetter = [sectionTitles objectAtIndex:indexPath.section];
    NSArray *objectsForLetter = [objectsPerLetterDictionary objectForKey:indexLetter];
    XASBaseObject *object = [objectsForLetter objectAtIndex:indexPath.row];
    
    // Configure the cell...
    if([object respondsToSelector:@selector(name)]) {
        cell.textLabel.text = [object performSelector:@selector(name) withObject:nil];
    }
    
    cell.backgroundColor = [UIColor greenColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *indexLetter = [sectionTitles objectAtIndex:indexPath.section];
    NSArray *objectsForLetter = [objectsPerLetterDictionary objectForKey:indexLetter];
    XASBaseObject *object = [objectsForLetter objectAtIndex:indexPath.row];
    
    [object fetchIfNeededInBackgroundWithBlock:^(XASBaseObject *downloadedObject, NSError *error) {
        if(error) {
            NSLog(@"Error :%@", error.localizedDescription);
        } else {
            NSLog(@"%@", downloadedObject);
        }
        
    }];
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

@end
