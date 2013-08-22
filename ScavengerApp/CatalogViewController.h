//
//  CatalogViewController.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/22/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatalogViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) GHCatalog *catalog;

@end
