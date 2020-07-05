//
//  MixtureLayoutViewController.m
//  ZBSimpleLayoutDemo
//
//  Created by Zombie on 2020/6/30.
//  Copyright © 2020 Zombie. All rights reserved.
//

#import "MixtureLayoutViewController.h"
#import "ZBSimpleCollectionViewLayout.h"

#import "TestCollectionReusableView.h"
#import "TestCollectionViewCell.h"
#import "MixtureLayoutDataManager.h"

static NSString * const kCellID = @"cell";
static NSString * const kHeaderID = @"cell";
static NSString * const kFooterID = @"cell";
static NSString * const kDecorationID = @"kDecorationID";

@interface MixtureLayoutViewController () <ZBSimpleCollectionViewLayoutDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) MixtureLayoutDataManager * dataManager;

@end

@implementation MixtureLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"混合布局";
    
    ZBSimpleCollectionViewLayout * layout = [[ZBSimpleCollectionViewLayout alloc]init];
    layout.delegate = self;
    
    UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    [layout registerClass:[TestCollectionReusableView class] forDecorationViewOfKind:kDecorationID];
    
    [_collectionView registerClass:[TestCollectionViewCell class] forCellWithReuseIdentifier:kCellID];
    [_collectionView registerClass:[TestCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderID];
    [_collectionView registerClass:[TestCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterID];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
    [self.dataManager createLayoutData];
}

#pragma mark - UICollectionViewDataSource
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TestCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"Section: %ld\nRow: %ld", indexPath.section, indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    MixtureLayoutDataModel * model = _dataManager.layoutData[section];
    return model.itemCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dataManager.layoutData.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSString * identifier, *prefix;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        identifier = kHeaderID;
        prefix = @"区头";
    } else {
        identifier = kFooterID;
        prefix = @"区尾";
    }
    TestCollectionReusableView * reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
    MixtureLayoutDataModel * model = _dataManager.layoutData[indexPath.section];
    reusableView.titleLabel.text = [NSString stringWithFormat:@"%@Section:%ld - %@", prefix, indexPath.section, model.title];
    
    return reusableView;
}

#pragma mark - ZBSimpleCollectionViewLayoutDelegate
/// 每个item的size （瀑布流布局时宽度设置无效，宽度根据布局列数自动计算）
- (CGSize)ZBSimpleCollectionViewLayoutItemSizeForIndexPath:(NSIndexPath *)indexPath {
    MixtureLayoutDataModel * model = _dataManager.layoutData[indexPath.section];
    if (model.layoutConfig.type == ZBCollectionViewLayoutFalls) {
        CGSize size = model.itemSize;
        size.height = arc4random() % 60 + 180;
        return size;
    }
    
    if (model.dataType == MixtureLayoutTypeSection1 && indexPath.row > 1) {
        CGSize size = model.itemSize;
        size.width = (CGRectGetWidth(self.collectionView.frame) - 40) / 3 - 0.01;
        return size;
    }
    if (model.dataType == MixtureLayoutTypeSection2 && indexPath.row % 3 > 0) {
        CGSize size = model.itemSize;
        size.height = (size.width - 10) / 2;
        return size;
    }
    if (model.dataType == MixtureLayoutTypeSection3 && indexPath.row % 4 > 0) {
        CGSize size = model.itemSize;
        size.height = (size.width - 20) / 3 - 0.01;
        return size;
    }
    return model.itemSize;
}

/// 每列的距离(item之间的距离)
- (CGFloat)ZBSimpleCollectionViewLayoutItemSpaceAtSection:(NSInteger)section {
    MixtureLayoutDataModel * model = _dataManager.layoutData[section];
    return model.itemSpace;
}
/// 每行的距离
- (CGFloat)ZBSimpleCollectionViewLayoutLineSpaceAtSection:(NSInteger)section {
    MixtureLayoutDataModel * model = _dataManager.layoutData[section];
    return model.lineSpace;
}

/// 返回每区布局类型基本配置
- (ZBCollectionViewLayoutTypeConfig)ZBSimpleCollectionViewLayoutTypeAtSection:(NSInteger)section {
    MixtureLayoutDataModel * model = _dataManager.layoutData[section];
    return model.layoutConfig;
}

/// 区的内间距
- (UIEdgeInsets)ZBSimpleCollectionViewLayoutSectionInsetsAtSection:(NSInteger)section{
    MixtureLayoutDataModel * model = _dataManager.layoutData[section];
    return model.sectionInsets;
}

/// 区头区尾大小（size.width超过最大值时会自动设置成最大值（滚动视图的宽减滚动视图左右内间距））
- (CGSize)ZBSimpleCollectionViewLayoutHeaderSizeAtSection:(NSInteger)section{
    MixtureLayoutDataModel * model = _dataManager.layoutData[section];
    return model.headerSize;
}
- (CGSize)ZBSimpleCollectionViewLayoutFooterSizeAtSection:(NSInteger)section{
    MixtureLayoutDataModel * model = _dataManager.layoutData[section];
    return model.footerSize;
}

/// 区的装饰视图大小
- (CGSize)ZBSimpleCollectionViewLayoutDecorationViewSizeAtSection:(NSInteger)section {
    MixtureLayoutDataModel * model = _dataManager.layoutData[section];
    return model.decorationSize;
}
/// 区的装饰视图基于本身大小的内偏移
- (UIEdgeInsets)ZBSimpleCollectionViewLayoutDecorationViewSizeInsetsAtSection:(NSInteger)section {
    MixtureLayoutDataModel * model = _dataManager.layoutData[section];
    return model.decorationInsets;
}
/// 区的装饰视图对应的注册kind（identity）
- (NSString *)ZBSimpleCollectionViewLayoutDecorationKindAtSection:(NSInteger)section {
    return kDecorationID;
}

- (MixtureLayoutDataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [[MixtureLayoutDataManager alloc]init];
    }
    return _dataManager;
}

@end
