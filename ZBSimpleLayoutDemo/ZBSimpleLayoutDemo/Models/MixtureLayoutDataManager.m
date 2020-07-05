//
//  MixtureLayoutDataManager.m
//  ZBSimpleLayoutDemo
//
//  Created by Zombie on 2020/7/3.
//  Copyright © 2020 Zombie. All rights reserved.
//

#import "MixtureLayoutDataManager.h"


@implementation MixtureLayoutDataManager

- (instancetype)init {
    if (self = [super init]) {
        
        
        
    }
    return self;
}

- (void)createLayoutData {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    NSMutableArray * array = [[NSMutableArray alloc]init];
    
    MixtureLayoutDataModel * section0 = [MixtureLayoutDataModel new];
    section0.dataType = MixtureLayoutTypeSection0;
    section0.layoutConfig = ZBConfigMake(ZBCollectionViewLayoutNormal, 0, 0, 0);
    section0.itemSize = CGSizeMake((screenWidth - 60)/4, (screenWidth - 60)/4);
    section0.headerSize = CGSizeZero;
    section0.footerSize = CGSizeZero;
    section0.decorationSize = CGSizeMake(screenWidth - 30, section0.itemSize.height);
    section0.lineSpace = 0;
    section0.itemSpace = 10;
    section0.sectionInsets = UIEdgeInsetsMake(5, 5, 10, 5);
    section0.decorationInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    section0.itemCount = 4;
    section0.title = @"";
    [array addObject:section0];
    
    MixtureLayoutDataModel * section1 = [MixtureLayoutDataModel new];
    section1.dataType = MixtureLayoutTypeSection1;
    section1.layoutConfig = ZBConfigMake(ZBCollectionViewLayoutNormal, 0, 0, 0);
    section1.itemSize = CGSizeMake((screenWidth - 30) / 2, (screenWidth - 30) / 2);
    section1.headerSize = CGSizeMake(screenWidth, 35);
    section1.footerSize = CGSizeMake(screenWidth - 20, 30);
    section1.decorationSize = CGSizeZero;
    section1.lineSpace = 10;
    section1.itemSpace = 10;
    section1.sectionInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    section1.decorationInsets = UIEdgeInsetsZero;
    section1.itemCount = 5;
    section1.title = @"普通布局";
    [array addObject:section1];
    
    MixtureLayoutDataModel * section2 = [MixtureLayoutDataModel new];
    section2.dataType = MixtureLayoutTypeSection2;
    section2.layoutConfig = ZBConfigMake(ZBCollectionViewLayoutMultiSplit, 0, 0, 0);
    section2.itemSize = CGSizeMake((screenWidth - 30) / 2, (screenWidth - 30) / 2);
    section2.headerSize = CGSizeMake(screenWidth, 35);
    section2.footerSize = CGSizeZero;
    section2.decorationSize = CGSizeZero;
    section2.lineSpace = 10;
    section2.itemSpace = 10;
    section2.sectionInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    section2.decorationInsets = UIEdgeInsetsZero;
    section2.itemCount = 6;
    section2.title = @"一拖N布局(左一右N)";
    [array addObject:section2];
    
    MixtureLayoutDataModel * section3 = [MixtureLayoutDataModel new];
    section3.dataType = MixtureLayoutTypeSection3;
    section3.layoutConfig = ZBConfigMake(ZBCollectionViewLayoutMultiSplit, 0, 3, YES);
    section3.itemSize = CGSizeMake((screenWidth - 30) / 2, (screenWidth - 30) / 2);
    section3.headerSize = CGSizeMake(screenWidth, 35);
    section3.footerSize = CGSizeZero;
    section3.decorationSize = CGSizeZero;
    section3.lineSpace = 10;
    section3.itemSpace = 10;
    section3.sectionInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    section3.decorationInsets = UIEdgeInsetsZero;
    section3.itemCount = 4;
    section3.title = @"一拖N布局(右一左N)";
    [array addObject:section3];
    
    MixtureLayoutDataModel * section4 = [MixtureLayoutDataModel new];
    section4.dataType = MixtureLayoutTypeSection4;
    section4.layoutConfig = ZBConfigMake(ZBCollectionViewLayoutFalls, 0, 0, 0);
    section4.itemSize = CGSizeZero;
    section4.headerSize = CGSizeMake(screenWidth, 35);
    section4.footerSize = CGSizeZero;
    section4.decorationSize = CGSizeZero;
    section4.lineSpace = 10;
    section4.itemSpace = 10;
    section4.sectionInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    section4.decorationInsets = UIEdgeInsetsZero;
    section4.itemCount = 10;
    section4.title = @"瀑布流布局";
    [array addObject:section4];
    
    _layoutData = array;
}

@end
