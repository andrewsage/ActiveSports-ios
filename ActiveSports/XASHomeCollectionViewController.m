//
//  XASHomeCollectionViewController.m
//  ActiveSports
//
//  Created by Andrew Sage on 24/12/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "XASHomeCollectionViewController.h"
#import "XASOpportunitiesTableViewController.h"
#import "XASMenuCollectionViewCell.h"
#import "XASRegion.h"
#import "XASOpportunity.h"
#import "MBProgressHUD.h"
#import "XASProfileBuiderViewController.h"

@interface XASHomeCollectionViewController () {
    MBProgressHUD *HUD;
    BOOL mCheckedForUpdated;
    BOOL mCheckedForPreferences;
    BOOL mHasData;
}

@end

@implementation XASHomeCollectionViewController

static NSString * const reuseIdentifier = @"menuoption";

- (void)checkForPreferences {

    NSDictionary *preferencesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self preferencesFilepath]];
    
    if(preferencesDictionary == nil) {
        preferencesDictionary = [NSMutableDictionary dictionary];
    }
    
    if(mCheckedForPreferences == NO) {
        if(preferencesDictionary.count == 0) {
            if([XASActivity dictionary].count > 0) {
                mCheckedForPreferences = YES;
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"Your activity preferences"
                                                      message:@"In order to help us recommend activities that are more relevant to you we would like to ask you some questions."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Continue", @"OK action")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
                                               
                                               XASProfileBuiderViewController *profileBuilderViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileBuilderViewController"];
                                               [self presentViewController:profileBuilderViewController
                                                                  animated:YES
                                                                completion:^{
                                                                    
                                                                }];
                                           }];
                
                [alertController addAction:okAction];
                
                [self presentViewController:alertController
                                   animated:YES
                                 completion:^{
                                     
                                 }];
                
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home-bg"]];
    
    mCheckedForUpdated = NO;
    mCheckedForPreferences = NO;
    mHasData = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionTop animated:NO];

    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // Display a welcome message and get the data if we don't have any
    if(mCheckedForUpdated == NO) {
        NSDictionary *dictionary = [XASOpportunity dictionary];
        if(dictionary.count == 0) {
            
            mCheckedForUpdated = YES;
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Welcome"
                                                  message:@"Thank you for using the Active Aberdeen app. Before we begin we will need to download activity information from our server."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Continue", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           [self updateData];
                                       }];
            
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action) {
                                               [self checkForPreferences];
                                           }];
            
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController
                               animated:YES
                             completion:^{
                                 
                             }];
        } else {
            mHasData = YES;
            [self.collectionView reloadData];
            [self checkForPreferences];
        }
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    
    if([segue.identifier isEqualToString:@"favourites"]) {
        XASOpportunitiesTableViewController *opportunitiesController = (XASOpportunitiesTableViewController*)segue.destinationViewController;
        opportunitiesController.viewType = XASOpportunitiesViewFavourites;
        
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return 8;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *titlesArray = @[@"What's on today?",
                             @"Advanced Search",
                             @"Saved Searches",
                             @"Favourite Activities",
                             @"Activity Preferences",
                             @"Venues",
                             @"Update Data",
                             @"About this app"];
    
    NSArray *iconNamesArray = @[@"home-whats-on",
                                @"home-advanced-search",
                                @"home-saved-searches",
                                @"home-fave-activities",
                                @"home-activity-prefs",
                                @"home-venues",
                                @"home-update",
                                @"home-about"];
    
    XASMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.text = [titlesArray objectAtIndex:indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:[iconNamesArray objectAtIndex:indexPath.row]];
    
    cell.bottomBorderLayer.frame = CGRectMake(0.0f, cell.frame.size.height - 1.0f, cell.frame.size.width, 1.0f);
    cell.bottomBorderLayer.backgroundColor = [UIColor colorWithWhite:0.5f
                                                     alpha:0.5f].CGColor;
    
    if(mHasData == NO && indexPath.row < 6) {
        cell.iconImageView.alpha = 0.5;
        cell.titleLabel.alpha = 0.5;
    } else {
        cell.iconImageView.alpha = 1.0;
        cell.titleLabel.alpha = 1.0;
    }
    
    if(indexPath.row % 2 == 0) {
        cell.rightBorderLayer.frame = CGRectMake(cell.frame.size.width - 1.0f, 0.0f, 1.0f, cell.frame.size.height);
        cell.rightBorderLayer.backgroundColor = [UIColor colorWithWhite:0.5f
                                                     alpha:0.5f].CGColor;
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Available height is the size of the collection view minus the header
    CGFloat height = collectionView.frame.size.height - 90;
    
    //You may want to create a divider to scale the size by the way..
    return CGSizeMake(collectionView.frame.size.width / 2, height /  4);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}


#pragma mark <UICollectionViewDelegate>

- (void)updateData {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Downloading data";
    
    XASRegion *region = [[XASRegion alloc] init];
    region.remoteID = @"4";
    
    [XASOpportunity fetchAllInBackgroundFor:region withBlock:^(NSArray *objects, NSError *error) {
        
        [hud hide:YES];

        if(error) {
            NSLog(@"error: %@", error.localizedDescription);
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Download Error"
                                                  message:[NSString stringWithFormat:@"There was a problem downloading data: %@", error.localizedDescription]
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController
                               animated:YES
                             completion:^{
                                 
                             }];

        } else {
            NSLog(@"Data updated");
            mHasData = YES;
            [self.collectionView reloadData];
            [self checkForPreferences];
        }
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            if(mHasData) {
                [self performSegueWithIdentifier:@"today" sender:self];
            }
            break;
            
        case 1:
            if(mHasData) {
                [self performSegueWithIdentifier:@"search" sender:self];
            }
            break;
            
        case 2:
            if(mHasData) {
                [self performSegueWithIdentifier:@"savedsearches" sender:self];
            }
            break;
            
        case 3:
            if(mHasData) {
                [self performSegueWithIdentifier:@"favourites" sender:self];
            }
            break;
            
        case 4:
            if(mHasData) {
                [self performSegueWithIdentifier:@"preferences" sender:self];
            }
            break;
            
        case 5:
            if(mHasData) {
                [self performSegueWithIdentifier:@"venues" sender:self];
            }
            break;
            
        case 6: {
            NSLog(@"Update data requested");
            
            [self updateData];

        }
            break;
            
        case 7:
            [self performSegueWithIdentifier:@"about" sender:self];
            break;
            
        default:
            break;
    }
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - Preferences
- (NSString*)preferencesFilepath {
    
    NSString *documentsDir = [XASBaseObject cacheDirectory];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"profile"]];
    
    return path;
}

@end
