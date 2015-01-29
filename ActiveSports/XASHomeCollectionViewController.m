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

@interface XASHomeCollectionViewController ()

@end

@implementation XASHomeCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
    
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
        opportunitiesController.viewType = XASOpportunitiesViewLikes;
        
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return 7;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = reuseIdentifier;
    
    switch(indexPath.row) {
        case 0:
            identifier = @"Today";
            break;
            
        case 1:
            identifier = @"Search";
            break;
            
        case 2:
            identifier = @"SavedSearches";
            break;
            
        case 3:
            identifier = @"Favourites";
            break;
            
        case 4:
            identifier = @"Preferences";
            break;
            
        case 5:
            identifier = @"Venues";
            break;
            
        case 6:
            identifier = @"About";
            break;
    }
    XASMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell
    //cell.layer.borderWidth = 1.0f;
    //cell.layer.borderColor = [UIColor whiteColor].CGColor;
    
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
