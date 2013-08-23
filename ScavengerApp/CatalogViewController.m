//
//  CatalogViewController.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/22/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CatalogViewController.h"
#import "SelectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "CatalogViewCollectionHeader.h"


#define kSELECTION_CELL_IDENTIFIER @"SelectionCell"
#define kSECTION_HEADER_IDENTIFIER @"CatalogViewCollectionHeader"

@interface CatalogViewController ()

@end

@implementation CatalogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    _catalog = [[AppState sharedInstance] currentCatalog]; //to move catalog in the singleton...
    
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewbackground"]]];
    
    
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:kSELECTION_CELL_IDENTIFIER bundle:nil] forCellWithReuseIdentifier:kSELECTION_CELL_IDENTIFIER];
    [self.collectionView registerNib:[UINib nibWithNibName:kSECTION_HEADER_IDENTIFIER bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSECTION_HEADER_IDENTIFIER];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_catalog count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    GHProfile *profile = [GHProfile modelObjectWithDictionary:[_catalog objectAtIndex:section]];
    return [[profile routes] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    GHRoute *route = [[[GHProfile modelObjectWithDictionary:[_catalog objectAtIndex:indexPath.section]] routes] objectAtIndex:indexPath.row];
    
    SelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSELECTION_CELL_IDENTIFIER forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:kSELECTION_CELL_IDENTIFIER owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbackground1"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbackground2"]];

    [cell.profileImage setImageWithURL:[NSURL URLWithString:[[route icon] url]]];
    cell.profileLabel.text = route.name;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
    
    
//    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
//    UILabel *label = [[UILabel alloc] initWithFrame:collectionView.bounds];
//    label.text = route.name;
//    [cell addSubview:label];
//
//    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CatalogViewCollectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSECTION_HEADER_IDENTIFIER forIndexPath:indexPath];
        if(headerView== nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:kSECTION_HEADER_IDENTIFIER owner:self options:nil];
            headerView = [nib objectAtIndex:0];

        }
        GHProfile *profile = [GHProfile modelObjectWithDictionary:[_catalog objectAtIndex:indexPath.section]];
        headerView.headerLabel.text = profile.name;
        [headerView.headerImage setImageWithURL:[NSURL URLWithString:profile.image.url]];
        
        reusableview = headerView;
    }
    
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize retval = CGSizeMake(100, 100);
    retval.height += 35; retval.width += 35;
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(30, 20, 30, 20);
}

@end
