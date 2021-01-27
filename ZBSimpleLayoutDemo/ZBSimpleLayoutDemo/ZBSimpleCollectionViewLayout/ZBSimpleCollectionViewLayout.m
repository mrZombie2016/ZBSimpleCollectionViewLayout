//
//  IndexCollectionViewLayout.m
//  YinTongStore
//
//  Created by Zombie on 2019/12/2.
//  Copyright © 2019 Zombie. All rights reserved.
//

#import "ZBSimpleCollectionViewLayout.h"

struct ZBCollectionViewLayoutConfig {
    ZBCollectionViewLayoutTypeConfig typeConfig;
    CGFloat lineSpace;
    CGFloat itemSpace;
    UIEdgeInsets insets;
};
typedef struct ZBCollectionViewLayoutConfig ZBCollectionViewLayoutConfig;

const ZBCollectionViewLayoutTypeConfig ZBLayoutTypeConfigDefault = {ZBCollectionViewLayoutNormal,2,2,NO};

@interface ZBSimpleCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray <__kindof UICollectionViewLayoutAttributes *>* attributes;
@property (nonatomic, assign) CGFloat calculateHeight;
@property (nonatomic, assign) CGFloat calculateWidth;
/// 保存瀑布流列高度
@property (nonatomic, strong) NSMutableDictionary * fallsDictionary;
/// 最后一区row数量
@property (nonatomic, assign) NSInteger lastSectionRowNumber;

/// 保存区头布局
@property (nonatomic, strong) NSMutableArray <__kindof UICollectionViewLayoutAttributes *>* sectionAttributes;
/// 保存区头初始默认的y坐标
@property (nonatomic, strong) NSMutableDictionary * sectionDefaultYs;

@end

@implementation ZBSimpleCollectionViewLayout

- (instancetype)init {
    if (self = [super init]) {
        _attributes = [[NSMutableArray alloc]init];
        _fallsDictionary = [[NSMutableDictionary alloc]init];
        _calculateHeight = 0;
        _calculateWidth = 0;
        _lastSectionRowNumber = 0;
        
        _sectionAttributes = [[NSMutableArray alloc]init];
        _sectionDefaultYs = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)resetLayoutData {
    [_attributes removeAllObjects];
    [_fallsDictionary removeAllObjects];
    [_sectionAttributes removeAllObjects];
    [_sectionDefaultYs removeAllObjects];
    _calculateHeight = 0;
    _calculateWidth = CGRectGetWidth(self.collectionView.frame) - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
}

- (void)prepareLayout {

    [super prepareLayout];
    
    NSInteger sectionNumber = [self.collectionView numberOfSections];
    if (sectionNumber <= 0) {
        [self resetLayoutData];
        return;
    }
    
    if ([self addAttributes]) {
        return;
    }
    
    [self resetLayoutData];
        
    for (NSInteger section = 0; section < sectionNumber; section ++) {
        NSInteger rowNumber = [self.collectionView numberOfItemsInSection:section];
        NSIndexPath * sIndexPath = [NSIndexPath indexPathWithIndex:section];
        
        UICollectionViewLayoutAttributes * supplementaryAttr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:sIndexPath];
        if (supplementaryAttr) {
            [_attributes addObject:supplementaryAttr];
            [_sectionAttributes addObject:supplementaryAttr];
        }
        
        NSString * decoration = [self ZBSimpleCollectionViewLayoutDecorationKindAtSection:section];
        if (decoration) {
            UICollectionViewLayoutAttributes * decorationAttr = [self layoutAttributesForDecorationViewOfKind:decoration atIndexPath:sIndexPath];
            if (decorationAttr) {
                [_attributes addObject:decorationAttr];
            }
        }
        
        ZBCollectionViewLayoutConfig config = {ZBLayoutTypeConfigDefault,0,0,UIEdgeInsetsZero};
        config.typeConfig = [self ZBSimpleCollectionViewLayoutTypeAtSection:section];
        config.lineSpace = [self ZBSimpleCollectionViewLayoutLineSpaceAtSection:section];
        config.itemSpace = [self ZBSimpleCollectionViewLayoutItemSpaceAtSection:section];
        config.insets = [self ZBSimpleCollectionViewLayoutSectionInsetsAtSection:section];
        
        [_fallsDictionary removeAllObjects];
        
        for (NSInteger row = 0; row < rowNumber; row ++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:row inSection:section];
            UICollectionViewLayoutAttributes * itemAttr = [self layoutAttributesForItemAtIndexPath:indexPath withConfig:config];
            if (itemAttr) {
                [_attributes addObject:itemAttr];
            }
        }
        
        UICollectionViewLayoutAttributes * footerAttr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:sIndexPath];
        if (footerAttr) {
            [_attributes addObject:footerAttr];
        }
        
    }
    
    

}

- (CGSize)collectionViewContentSize{
    CGFloat height = _calculateHeight;
    CGFloat width = _calculateWidth;
    
    UICollectionViewLayoutAttributes * lastAttributes = self.attributes.lastObject;
    if (height < CGRectGetMaxY(lastAttributes.frame)) {
        height = CGRectGetMaxY(lastAttributes.frame);
    }
    
    return CGSizeMake(width, height);
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
     return _attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutHeaderPinToTopAtSection:)]) {
        return NO;
    }
    for (UICollectionViewLayoutAttributes * attributes in _sectionAttributes) {
        if ([self ZBSimpleCollectionViewLayoutHeaderPinToTopAtSection:attributes.indexPath.section]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)addAttributes {
    NSInteger sectionNumber = [self.collectionView numberOfSections];
    NSInteger lastSection = sectionNumber - 1;
    NSInteger lastSectionRowNumber = [self.collectionView numberOfItemsInSection:lastSection];
    if (_updateData) {
        _updateData = NO;
        
        if (lastSectionRowNumber == _lastSectionRowNumber) {
            return YES;
        }
        if (lastSectionRowNumber < _lastSectionRowNumber) {
            _lastSectionRowNumber = lastSectionRowNumber;
            return NO;
        }
        NSIndexPath * sIndexPath = [NSIndexPath indexPathWithIndex:lastSection];
        UICollectionViewLayoutAttributes * lastAttr = _attributes.lastObject;
        if (lastAttr.indexPath.section == lastSection && lastAttr.representedElementCategory == UICollectionElementCategorySupplementaryView) {
            _calculateHeight -= lastAttr.frame.size.height;
            [_attributes removeObject:lastAttr];
        }
        
        NSInteger decoration = (_attributes.count - _lastSectionRowNumber) - 1;
        if (_attributes.count && (decoration >= 0)) {
            UICollectionViewLayoutAttributes * decorationAttr = [_attributes objectAtIndex:decoration];
            if (decorationAttr.representedElementCategory == UICollectionElementCategoryDecorationView && decorationAttr.indexPath.section == lastSection) {
                CGSize size = [self ZBSimpleCollectionViewLayoutDecorationViewSizeAtSection:sIndexPath.section];
                if (CGSizeEqualToSize(size, CGSizeZero)) {
                    [_attributes removeObject:decorationAttr];
                } else {
                    UIEdgeInsets sizeInsets = [self ZBSimpleCollectionViewLayoutDecorationViewSizeInsetsAtSection:sIndexPath.section];
                    decorationAttr.frame = CGRectMake(decorationAttr.frame.origin.x, decorationAttr.frame.origin.y, decorationAttr.frame.size.width, size.height - sizeInsets.top - sizeInsets.bottom);
                }
                
            }
        }
        
        ZBCollectionViewLayoutConfig config = {ZBLayoutTypeConfigDefault,0,0,UIEdgeInsetsZero};
        config.typeConfig = [self ZBSimpleCollectionViewLayoutTypeAtSection:lastSection];
        config.lineSpace = [self ZBSimpleCollectionViewLayoutLineSpaceAtSection:lastSection];
        config.itemSpace = [self ZBSimpleCollectionViewLayoutItemSpaceAtSection:lastSection];
        config.insets = [self ZBSimpleCollectionViewLayoutSectionInsetsAtSection:lastSection];
        for (NSInteger row = _lastSectionRowNumber; row < lastSectionRowNumber; row ++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:row inSection:lastSection];
            UICollectionViewLayoutAttributes * itemAttr = [self layoutAttributesForItemAtIndexPath:indexPath withConfig:config];
            if (itemAttr) {
                [_attributes addObject:itemAttr];
            }
        }
        UICollectionViewLayoutAttributes * footerAttr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:sIndexPath];
        if (footerAttr) {
            [_attributes addObject:footerAttr];
        }
        
        
        _lastSectionRowNumber = lastSectionRowNumber;
        return YES;
    }
    _lastSectionRowNumber = lastSectionRowNumber;
    return NO;
}

///Item
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath withConfig:(ZBCollectionViewLayoutConfig)config {
    
    CGSize size = [self ZBSimpleCollectionViewLayoutItemSizeForIndexPath:indexPath];
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    ZBCollectionViewLayoutType type = config.typeConfig.type;
    CGFloat lineSpace = config.lineSpace;
    CGFloat itemSpace = config.itemSpace;
    UIEdgeInsets insets = config.insets;
    
    
    UICollectionViewLayoutAttributes * lastAttributes = self.attributes.lastObject;
    CGRect lastFrame = lastAttributes.frame;
    
    CGFloat x = insets.left;
    CGFloat y = _calculateHeight + insets.top;
    
    switch (type) {
        case ZBCollectionViewLayoutNormal:
        {
            if (indexPath.row > 0) {
                
                CGFloat maxContentFromLeft = _calculateWidth - insets.right;
                if (maxContentFromLeft >= CGRectGetMaxX(lastFrame) + itemSpace + size.width) {
                    x = CGRectGetMaxX(lastFrame) + itemSpace;
                    y = CGRectGetMinY(lastFrame);
                } else {
                    y = CGRectGetMaxY(lastFrame) + lineSpace;
                }
                
                
            }
            
        }

            break;
            
        case ZBCollectionViewLayoutMultiSplit:
        {
            NSInteger multiSplit = config.typeConfig.multiSplit;
            BOOL oneAtRight = config.typeConfig.oneAtRight;
            if (multiSplit < 2) {
                multiSplit = 2;
            }
            NSInteger oneByMultiIndex = indexPath.row % (multiSplit + 1);
            if (oneByMultiIndex == 0) {
                if (indexPath.row != 0) {
                    y = CGRectGetMaxY(lastFrame) + lineSpace;
                }
                if (oneAtRight) {
                    x = _calculateWidth - insets.right - size.width;
                }
            }
            else if (oneByMultiIndex == 1) {
                y = CGRectGetMinY(lastFrame);
                x = CGRectGetMaxX(lastFrame) + itemSpace;
                if (oneAtRight) {
                    x = CGRectGetMinX(lastFrame) - itemSpace - size.width;
                }
            }
            else {
                y = CGRectGetMaxY(lastFrame) + lineSpace;
                x = CGRectGetMinX(lastFrame);
                if (oneAtRight) {
                    x = CGRectGetMaxX(lastFrame) - size.width;
                }
            }
            
        }
            break;
            
        case ZBCollectionViewLayoutFalls:
        {
            NSInteger falls = config.typeConfig.falls;
            if (falls < 2) {
                falls = 2;
            }
            
            CGFloat minY = [_fallsDictionary[@0] floatValue];
            NSInteger minYFall = 0;
            for (NSInteger i = 0; i < falls; i ++) {
                NSNumber *key = @(i);
                if (indexPath.row == 0) {
                    [_fallsDictionary setObject:@(y) forKey:key];
                    minY = y;
                } else {
                    CGFloat fallsY = [_fallsDictionary[key] floatValue];
                    if (fallsY < minY) {
                        minY = fallsY;
                        minYFall = i;
                    }
                }
            }
            
            size.width = (_calculateWidth - insets.left - insets.right - itemSpace * (falls - 1)) / falls;
            x = insets.left + (size.width + itemSpace) * minYFall;
            y = minY + ((falls > indexPath.row) ? 0 : lineSpace);
            
            [_fallsDictionary setObject:@(y + size.height) forKey:@(minYFall)];
        }
            break;
            
        default:
            break;
    }
    
    
    
    UICollectionViewLayoutAttributes * itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    itemAttributes.frame = CGRectMake(x, y, size.width, size.height);
    
    if (y + size.height + insets.bottom > _calculateHeight) {
        _calculateHeight = y + size.height + insets.bottom;
    }
    
    return itemAttributes;
}

///追加视图
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        size = [self ZBSimpleCollectionViewLayoutHeaderSizeAtSection:indexPath.section];
    } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        size = [self ZBSimpleCollectionViewLayoutFooterSizeAtSection:indexPath.section];
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    
    if (size.width > _calculateWidth) {
        size.width = _calculateWidth;
    }
        
    UICollectionViewLayoutAttributes * supplementaryAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    supplementaryAttributes.zIndex = 0;
    
    //判断是否悬浮
    BOOL pinToTop = [self ZBSimpleCollectionViewLayoutHeaderPinToTopAtSection:indexPath.section];
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader] && pinToTop) {
        CGFloat offset = [self ZBSimpleCollectionViewLayoutHeaderPinToTopOffsetAtSection:indexPath.section];
        CGFloat shouldOffset = self.collectionView.contentOffset.y + offset;
        if (@available(iOS 11.0, *)) {
            shouldOffset += self.collectionView.safeAreaInsets.top;
        }
        if (shouldOffset >= _calculateHeight) {

            supplementaryAttributes.zIndex = 1;
            supplementaryAttributes.frame = CGRectMake(0, shouldOffset, size.width, size.height);
        } else {
            supplementaryAttributes.frame = CGRectMake(0, MAX(_calculateHeight, supplementaryAttributes.frame.origin.y), size.width, size.height);
            
        }
        UICollectionViewLayoutAttributes * lastSectionAttributes = _sectionAttributes.lastObject;
        if (lastSectionAttributes
            && CGRectGetMinY(lastSectionAttributes.frame) != [_sectionDefaultYs[lastSectionAttributes.indexPath] floatValue]
            && CGRectGetMaxY(lastSectionAttributes.frame) + offset >= CGRectGetMinY(supplementaryAttributes.frame)) {
            
            lastSectionAttributes.frame = CGRectMake(CGRectGetMinX(lastSectionAttributes.frame), CGRectGetMinY(supplementaryAttributes.frame) - offset - CGRectGetHeight(lastSectionAttributes.frame), CGRectGetWidth(lastSectionAttributes.frame), CGRectGetHeight(lastSectionAttributes.frame));
            
        }
        [_sectionDefaultYs setObject:@(_calculateHeight) forKey:indexPath];
    } else {
        supplementaryAttributes.frame = CGRectMake(0, _calculateHeight, size.width, size.height);
    }
    
    
    _calculateHeight += size.height;
    
    return supplementaryAttributes;
}

///装饰视图
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [self ZBSimpleCollectionViewLayoutDecorationViewSizeAtSection:indexPath.section];
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    
    UIEdgeInsets insets = [self ZBSimpleCollectionViewLayoutSectionInsetsAtSection:indexPath.section];
    
    UIEdgeInsets sizeInsets = [self ZBSimpleCollectionViewLayoutDecorationViewSizeInsetsAtSection:indexPath.section];
    
    UICollectionViewLayoutAttributes * decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];

    if (size.width > _calculateWidth - insets.left - insets.right) {
        size.width = _calculateWidth - insets.left - insets.right;
    }
    decorationAttributes.frame = CGRectMake(insets.left + sizeInsets.left, _calculateHeight + insets.top + sizeInsets.top, size.width - sizeInsets.left - sizeInsets.right, size.height - sizeInsets.top - sizeInsets.bottom);
    decorationAttributes.zIndex = -1;
    return decorationAttributes;
}

#pragma mark - 判断代理是否可用，返回可用数据
- (CGSize)ZBSimpleCollectionViewLayoutDecorationViewSizeAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutDecorationViewSizeAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutDecorationViewSizeAtSection:section];
    }
    return CGSizeZero;
}

- (UIEdgeInsets)ZBSimpleCollectionViewLayoutDecorationViewSizeInsetsAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutDecorationViewSizeInsetsAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutDecorationViewSizeInsetsAtSection:section];
    }
    return UIEdgeInsetsZero;
}

- (CGSize)ZBSimpleCollectionViewLayoutHeaderSizeAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutHeaderSizeAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutHeaderSizeAtSection:section];
    }
    return CGSizeZero;
}

- (CGSize)ZBSimpleCollectionViewLayoutFooterSizeAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutFooterSizeAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutFooterSizeAtSection:section];
    }
    return CGSizeZero;
}

- (CGSize)ZBSimpleCollectionViewLayoutItemSizeForIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutItemSizeForIndexPath:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutItemSizeForIndexPath:indexPath];
    }
    return CGSizeZero;
}

- (CGFloat)ZBSimpleCollectionViewLayoutItemSpaceAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutItemSpaceAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutItemSpaceAtSection:section];
    }
    return 0;
}

- (CGFloat)ZBSimpleCollectionViewLayoutLineSpaceAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutLineSpaceAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutLineSpaceAtSection:section];
    }
    return 0;
}

- (UIEdgeInsets)ZBSimpleCollectionViewLayoutSectionInsetsAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutSectionInsetsAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutSectionInsetsAtSection:section];
    }
    return UIEdgeInsetsZero;
}

- (ZBCollectionViewLayoutTypeConfig)ZBSimpleCollectionViewLayoutTypeAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutTypeAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutTypeAtSection:section];
    }
    ZBCollectionViewLayoutTypeConfig config;
    config.type = ZBCollectionViewLayoutNormal;
    return config;
}

- (NSString *)ZBSimpleCollectionViewLayoutDecorationKindAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutDecorationKindAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutDecorationKindAtSection:section];
    }
    return nil;
}

- (BOOL)ZBSimpleCollectionViewLayoutHeaderPinToTopAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutHeaderPinToTopAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutHeaderPinToTopAtSection:section];
    }
    return NO;
}

- (CGFloat)ZBSimpleCollectionViewLayoutHeaderPinToTopOffsetAtSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZBSimpleCollectionViewLayoutHeaderPinToTopOffsetAtSection:)]) {
        return [self.delegate ZBSimpleCollectionViewLayoutHeaderPinToTopOffsetAtSection:section];
    }
    return 0;
}

@end
