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

@interface XASHomeCollectionViewController ()

@end

@implementation XASHomeCollectionViewController

static NSString * const reuseIdentifier = @"button";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home-bg"]];
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
                                @"home-about",
                                @"home-about"];
    
    
    NSString *identifier = reuseIdentifier;
    

    XASMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"menuoption" forIndexPath:indexPath];
    
    // Configure the cell
    //cell.layer.borderWidth = 1.0f;
    //cell.layer.borderColor = [UIColor whiteColor].CGColor;
    
    cell.titleLabel.text = [titlesArray objectAtIndex:indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:[iconNamesArray objectAtIndex:indexPath.row]];
    
    cell.bottomBorderLayer.frame = CGRectMake(0.0f, cell.frame.size.height - 1.0f, cell.frame.size.width, 1.0f);
    cell.bottomBorderLayer.backgroundColor = [UIColor colorWithWhite:0.5f
                                                     alpha:0.5f].CGColor;
    
    
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"today" sender:self];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"search" sender:self];
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"savedsearches" sender:self];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"favourites" sender:self];
            break;
            
        case 4:
            [self performSegueWithIdentifier:@"preferences" sender:self];
            break;
            
        case 5:
            [self performSegueWithIdentifier:@"venues" sender:self];
            break;
            
        case 7:
            [self performSegueWithIdentifier:@"about" sender:self];
            break;
            
        default:
            break;
    }
    
    if(indexPath.row == 6) {
        
        NSLog(@"Update data requested");
        
        XASRegion *region = [[XASRegion alloc] init];
        region.remoteID = @"4";
        
        [XASOpportunity fetchAllInBackgroundFor:region withBlock:^(NSArray *objects, NSError *error) {
            
            if(error) {
                NSLog(@"error: %@", error.localizedDescription);
            } else {
                NSLog(@"Data updated");
            }
        }];
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

@end
