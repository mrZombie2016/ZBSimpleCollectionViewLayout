//
//  FallsLayoutViewController.m
//  ZBSimpleLayoutDemo
//
//  Created by Zombie on 2020/6/30.
//  Copyright © 2020 Zombie. All rights reserved.
//

#import "FallsLayoutViewController.h"
#import "ZBSimpleCollectionViewLayout.h"

#import "TestCollectionViewCell.h"

@interface FallsLayoutViewController () <ZBSimpleCollectionViewLayoutDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * collectionView;

@end

@implementation FallsLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"瀑布流布局";
    
    ZBSimpleCollectionViewLayout * layout = [[ZBSimpleCollectionViewLayout alloc]init];
    layout.delegate = self;
    
    UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.view addSubview:collectionView];
    [collectionView registerClass:[TestCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView = collectionView;
    
    
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - ZBSimpleCollectionViewLayoutDelegate
- (CGSize)ZBSimpleCollectionViewLayoutItemSizeForIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(0, 180 + arc4random() % 50);
}

- (CGFloat)ZBSimpleCollectionViewLayoutItemSpaceAtSection:(NSInteger)section {
    return 10;
}

- (CGFloat)ZBSimpleCollectionViewLayoutLineSpaceAtSection:(NSInteger)section {
    return 10;
}

- (ZBCollectionViewLayoutTypeConfig)ZBSimpleCollectionViewLayoutTypeAtSection:(NSInteger)section {
    ZBCollectionViewLayoutTypeConfig config = ZBLayoutTypeConfigDefault;
    config.type = ZBCollectionViewLayoutFalls;
    config.falls = 2;
    return config;
}

#pragma mark - UICollectionViewDataSource
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TestCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"Section: %ld\nRow: %ld", indexPath.section, indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

@end
